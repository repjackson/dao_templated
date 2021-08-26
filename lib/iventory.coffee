# if Meteor.isClient
    # Template.items.onCreated ->
    #     @autorun => @subscribe 'model_docs', 'item', ->
    # Router.route '/items', (->
    #     @render 'items'
    #     ), name:'items'

    # Template.items.onCreated ->
    #     @autorun -> Meteor.subscribe 'items',
    #         Session.get('item_status_filter')
    #     # @autorun -> Meteor.subscribe 'model_docs', 'product', 20
    #     # @autorun -> Meteor.subscribe 'model_docs', 'thing', 100

    # Template.items.helpers
    #     items: ->
    #         match = {model:'item'}
    #         if Session.get('item_status_filter')
    #             match.status = Session.get('item_status_filter')
    #         if Session.get('item_delivery_filter')
    #             match.delivery_method = Session.get('item_sort_filter')
    #         if Session.get('item_sort_filter')
    #             match.delivery_method = Session.get('item_sort_filter')
    #         Docs.find match,
    #             sort: _timestamp:-1


if Meteor.isClient
    Router.route '/item/:doc_id', (->
        @layout 'layout'
        @render 'item_view'
        ), name:'item_view'


    Template.item_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'product_by_item_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'item_things', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'review_from_item_id', Router.current().params.doc_id


    Template.item_view.events
        'click .mark_viewed': ->
            # if confirm 'mark viewed?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    runner_viewed: true
                    runner_viewed_timestamp: Date.now()
                    runner_username: Meteor.user().username
                    status: 'viewed' 
      
        'click .mark_preparing': ->
            # if confirm 'mark mark_preparing?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    preparing: true
                    preparing_timestamp: Date.now()
                    status: 'preparing' 
       
        'click .mark_prepared': ->
            # if confirm 'mark prepared?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    prepared: true
                    prepared_timestamp: Date.now()
                    status: 'prepared' 
     
        'click .mark_arrived': ->
            # if confirm 'mark arrived?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    arrived: true
                    arrived_timestamp: Date.now()
                    status: 'arrived' 
        
        'click .mark_delivering': ->
            # if confirm 'mark delivering?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    delivering: true
                    delivering_timestamp: Date.now()
                    status: 'delivering' 
      
        'click .mark_delivered': ->
            # if confirm 'mark delivered?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    delivered: true
                    delivered_timestamp: Date.now()
                    status: 'delivered' 
      
        'click .delete_item': ->
            thing_count = Docs.find(model:'thing').count()
            if confirm "delete? #{thing_count} things still"
                Docs.remove @_id
                Router.go "/items"
    
        'click .mark_ready': ->
            if confirm 'mark ready?'
                Docs.insert 
                    model:'item_event'
                    item_id: Router.current().params.doc_id
                    item_status:'ready'

        'click .add_review': ->
            Docs.insert 
                model:'item_review'
                item_id: Router.current().params.doc_id
                
                
        'click .review_positive': ->
            Docs.update @_id,
                $set:
                    rating:1
        'click .review_negative': ->
            Docs.update @_id,
                $set:
                    rating:-1

    Template.item_view.helpers
        item_review: ->
            Docs.findOne 
                model:'item_review'
                item_id:Router.current().params.doc_id
    
        can_item: ->
            # if StripeCheckout
            unless @_author_id is Meteor.userId()
                item_count =
                    Docs.find(
                        model:'item'
                        item_id:@_id
                    ).count()
                if item_count is @servings_amount
                    false
                else
                    true
            # else
            #     false




if Meteor.isServer
    Meteor.publish 'items', (item_id, status)->
        # item = Docs.findOne item_id
        match = {model:'item'}
        if status 
            match.status = status

        Docs.find match
        
    Meteor.publish 'review_from_item_id', (item_id)->
        # item = Docs.findOne item_id
        # match = {model:'item'}
        Docs.find 
            model:'item_review'
            item_id:item_id
        
    Meteor.publish 'product_by_item_id', (item_id)->
        item = Docs.findOne item_id
        Docs.find
            _id: item.product_id
    Meteor.publish 'item_things', (item_id)->
        item = Docs.findOne item_id
        Docs.find
            model:'thing'
            item_id: item_id

    # Meteor.methods
        # item_item: (item_id)->
        #     item = Docs.findOne item_id
        #     Docs.insert
        #         model:'item'
        #         item_id: item._id
        #         item_price: item.price_per_serving
        #         buyer_id: Meteor.userId()
        #     Meteor.users.update Meteor.userId(),
        #         $inc:credit:-item.price_per_serving
        #     Meteor.users.update item._author_id,
        #         $inc:credit:item.price_per_serving
        #     Meteor.call 'calc_item_data', item_id, ->


if Meteor.isServer
    Meteor.publish 'product_from_item_id', (item_id)->
        item = Docs.findOne item_id
        Docs.find
            model:'product'
            _id: item.product_id


if Meteor.isClient
    Router.route '/item/:doc_id/edit', (->
        @layout 'layout'
        @render 'item_edit'
        ), name:'item_edit'



    Template.item_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'source'

    Template.item_edit.onRendered ->
        # Meteor.setTimeout ->
        #     today = new Date()
        #     $('#availability')
        #         .calendar({
        #             inline:true
        #             # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
        #             # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
        #         })
        # , 2000

    Template.item_edit.helpers
        balance_after_purchase: ->
            Meteor.user().points - @purchase_amount
        percent_difference: ->
            balance_after_purchase = 
                Meteor.user().points - @purchase_amount
            # difference
            @purchase_amount/Meteor.user().points
    Template.item_edit.events
        'click .complete_item': (e,t)->
            console.log @
            Session.set('iteming',true)
            if @purchase_amount
                if Meteor.user().points and @purchase_amount < Meteor.user().points
                    Meteor.call 'complete_item', @_id, =>
                        Router.go "/product/#{@product_id}"
                        Session.set('iteming',false)
                else 
                    alert "not enough points"
                    Router.go "/user/#{Meteor.user().username}/points"
                    Session.set('iteming',false)
            else 
                alert 'no purchase amount'
            
            
        'click .delete_item': ->
            Docs.remove @_id
            Router.go "/product/#{@product_id}"
