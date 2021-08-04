if Meteor.isClient
    Router.route '/checkins', (->
        @render 'checkins'
        ), name:'checkins'

    Template.checkins.onCreated ->
        @autorun -> Meteor.subscribe 'checkins',
            Session.get('checkin_status_filter')
        # @autorun -> Meteor.subscribe 'model_docs', 'product', 20
        # @autorun -> Meteor.subscribe 'model_docs', 'thing', 100

    Template.checkins.helpers
        checkins: ->
            match = {model:'checkin'}
            if Session.get('checkin_status_filter')
                match.status = Session.get('checkin_status_filter')
            if Session.get('checkin_delivery_filter')
                match.delivery_method = Session.get('checkin_sort_filter')
            if Session.get('checkin_sort_filter')
                match.delivery_method = Session.get('checkin_sort_filter')
            Docs.find match,
                sort: _timestamp:-1


if Meteor.isClient
    Router.route '/checkin/:doc_id', (->
        @layout 'layout'
        @render 'checkin_view'
        ), name:'checkin_view'


    Template.checkin_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'product_by_checkin_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'checkin_things', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'review_from_checkin_id', Router.current().params.doc_id


    Template.checkin_view.events
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
      
        'click .delete_checkin': ->
            thing_count = Docs.find(model:'thing').count()
            if confirm "delete? #{thing_count} things still"
                Docs.remove @_id
                Router.go "/checkins"
    
        'click .mark_ready': ->
            if confirm 'mark ready?'
                Docs.insert 
                    model:'checkin_event'
                    checkin_id: Router.current().params.doc_id
                    checkin_status:'ready'

        'click .add_review': ->
            Docs.insert 
                model:'checkin_review'
                checkin_id: Router.current().params.doc_id
                
                
        'click .review_positive': ->
            Docs.update @_id,
                $set:
                    rating:1
        'click .review_negative': ->
            Docs.update @_id,
                $set:
                    rating:-1

    Template.checkin_view.helpers
        checkin_review: ->
            Docs.findOne 
                model:'checkin_review'
                checkin_id:Router.current().params.doc_id
    
        can_checkin: ->
            # if StripeCheckout
            unless @_author_id is Meteor.userId()
                checkin_count =
                    Docs.find(
                        model:'checkin'
                        checkin_id:@_id
                    ).count()
                if checkin_count is @servings_amount
                    false
                else
                    true
            # else
            #     false




if Meteor.isServer
    Meteor.publish 'checkins', (checkin_id, status)->
        # checkin = Docs.findOne checkin_id
        match = {model:'checkin'}
        if status 
            match.status = status

        Docs.find match
        
    Meteor.publish 'review_from_checkin_id', (checkin_id)->
        # checkin = Docs.findOne checkin_id
        # match = {model:'checkin'}
        Docs.find 
            model:'checkin_review'
            checkin_id:checkin_id
        
    Meteor.publish 'product_by_checkin_id', (checkin_id)->
        checkin = Docs.findOne checkin_id
        Docs.find
            _id: checkin.product_id
    Meteor.publish 'checkin_things', (checkin_id)->
        checkin = Docs.findOne checkin_id
        Docs.find
            model:'thing'
            checkin_id: checkin_id

    # Meteor.methods
        # checkin_checkin: (checkin_id)->
        #     checkin = Docs.findOne checkin_id
        #     Docs.insert
        #         model:'checkin'
        #         checkin_id: checkin._id
        #         checkin_price: checkin.price_per_serving
        #         buyer_id: Meteor.userId()
        #     Meteor.users.update Meteor.userId(),
        #         $inc:credit:-checkin.price_per_serving
        #     Meteor.users.update checkin._author_id,
        #         $inc:credit:checkin.price_per_serving
        #     Meteor.call 'calc_checkin_data', checkin_id, ->



if Meteor.isClient
    Template.user_checkin_item.onCreated ->
        # @autorun => Meteor.subscribe 'product_from_checkin_id', @data._id
    Template.user_checkins.onCreated ->
        @autorun => Meteor.subscribe 'user_checkins', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'product'
    Template.user_checkins.helpers
        checkins: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'checkin'
            }, sort:_timestamp:-1

if Meteor.isServer
    # Meteor.publish 'user_checkins', (username)->
    #     # user = Meteor.users.findOne username:username
    #     Docs.find 
    #         model:'checkin'
    #         _author_username:username
            
    
    Meteor.publish 'user_checkins', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'checkin'
            _author_id: user._id
        }, 
            limit:20
            sort:_timestamp:-1
            
    Meteor.publish 'product_from_checkin_id', (checkin_id)->
        checkin = Docs.findOne checkin_id
        Docs.find
            model:'product'
            _id: checkin.product_id


if Meteor.isClient
    Router.route '/checkin/:doc_id/edit', (->
        @layout 'layout'
        @render 'checkin_edit'
        ), name:'checkin_edit'



    Template.checkin_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'source'

    Template.checkin_edit.onRendered ->
        # Meteor.setTimeout ->
        #     today = new Date()
        #     $('#availability')
        #         .calendar({
        #             inline:true
        #             # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
        #             # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
        #         })
        # , 2000

    Template.checkin_edit.helpers
        balance_after_purchase: ->
            Meteor.user().points - @purchase_amount
        percent_difference: ->
            balance_after_purchase = 
                Meteor.user().points - @purchase_amount
            # difference
            @purchase_amount/Meteor.user().points
    Template.checkin_edit.events
        'click .complete_checkin': (e,t)->
            # console.log @
            Session.set('checking_in',true)
            Meteor.users.update Meteor.userId(),    
                $set:
                    checkedin:true
            Router.go "/user/#{Meteor.user().username}/"
            Session.set('checking_in',false)
            # if @purchase_amount
            # if Meteor.user().points and @purchase_amount < Meteor.user().points
            # Meteor.call 'complete_checkin', @_id, =>
            #     Router.go "/product/#{@product_id}"
            #     Session.set('checkining',false)
            #     else 
            #         alert "not enough points"
            #         Router.go "/user/#{Meteor.user().username}/points"
            #         Session.set('checkining',false)
            # else 
            #     alert 'no purchase amount'
            
            
        'click .delete_checkin': ->
            Docs.remove @_id
            Router.go "/product/#{@product_id}"


    Template.linked_product.onCreated ->
        # console.log @data
        @autorun => Meteor.subscribe 'doc_by_id', @data.product_id, ->

    Template.linked_product.helpers
        linked_product_doc: ->
            console.log @
            Docs.findOne @product_id
            
            
if Meteor.isServer
    Meteor.methods  
        complete_checkin: (checkin_id)->
            console.log 'completing checkin', checkin_id
            current_checkin = Docs.findOne checkin_id            
            Docs.update checkin_id, 
                $set:
                    status:'purchased'
                    purchased:true
                    purchase_timestamp: Date.now()
            console.log 'marked complete'
            Meteor.call 'calc_user_points', @_author_id, ->