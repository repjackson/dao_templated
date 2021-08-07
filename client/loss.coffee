if Meteor.isClient
    Router.route '/losses', (->
        @render 'losses'
        ), name:'losses'
    Router.route '/user/:username/losses', (->
        @render 'user_losses'
        ), name:'user_losses'

    Template.losses.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'loss'
        # @autorun -> Meteor.subscribe 'losses',
        #     Session.get('loss_status_filter')
        # @autorun -> Meteor.subscribe 'model_docs', 'product', 20
        # @autorun -> Meteor.subscribe 'model_docs', 'thing', 100
    Template.losses.events
        'click .add_loss': ->
            new_id = 
                Docs.insert 
                    model:'loss'
            Router.go "/loss/#{new_id}/edit"

    Template.losses.events
        'click .new_loss': ->
            new_id = 
                Docs.insert 
                    model:'loss'
            Router.go "/loss/#{new_id}/edit"


    Template.losses.helpers
        losses: ->
            match = {model:'loss'}
            if Session.get('loss_status_filter')
                match.status = Session.get('loss_status_filter')
            if Session.get('loss_delivery_filter')
                match.delivery_method = Session.get('loss_sort_filter')
            if Session.get('loss_sort_filter')
                match.delivery_method = Session.get('loss_sort_filter')
            Docs.find match,
                sort: _timestamp:-1


if Meteor.isClient
    Router.route '/loss/:doc_id', (->
        @layout 'layout'
        @render 'loss_view'
        ), name:'loss_view'


    Template.loss_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'product_by_loss_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'loss_things', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'review_from_loss_id', Router.current().params.doc_id


    Template.loss_view.events
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
       
        'click .delete_loss': ->
            thing_count = Docs.find(model:'thing').count()
            if confirm "delete? #{thing_count} things still"
                Docs.remove @_id
                Router.go "/losses"
    
        'click .mark_ready': ->
            if confirm 'mark ready?'
                Docs.insert 
                    model:'loss_event'
                    loss_id: Router.current().params.doc_id
                    loss_status:'ready'

        'click .add_review': ->
            Docs.insert 
                model:'loss_review'
                loss_id: Router.current().params.doc_id
                
                
        'click .review_positive': ->
            Docs.update @_id,
                $set:
                    rating:1
        'click .review_negative': ->
            Docs.update @_id,
                $set:
                    rating:-1

    Template.loss_view.helpers
        loss_review: ->
            Docs.findOne 
                model:'loss_review'
                loss_id:Router.current().params.doc_id
    
        can_loss: ->
            # if StripeCheckout
            unless @_author_id is Meteor.userId()
                loss_count =
                    Docs.find(
                        model:'loss'
                        loss_id:@_id
                    ).count()
                if loss_count is @servings_amount
                    false
                else
                    true
            # else
            #     false




if Meteor.isServer
    Meteor.publish 'losses', (loss_id, status)->
        # loss = Docs.findOne loss_id
        match = {model:'loss'}
        if status 
            match.status = status

        Docs.find match
        
    Meteor.publish 'review_from_loss_id', (loss_id)->
        # loss = Docs.findOne loss_id
        # match = {model:'loss'}
        Docs.find 
            model:'loss_review'
            loss_id:loss_id
        
    Meteor.publish 'product_by_loss_id', (loss_id)->
        loss = Docs.findOne loss_id
        Docs.find
            _id: loss.product_id
    Meteor.publish 'loss_things', (loss_id)->
        loss = Docs.findOne loss_id
        Docs.find
            model:'thing'
            loss_id: loss_id

    # Meteor.methods
        # loss_loss: (loss_id)->
        #     loss = Docs.findOne loss_id
        #     Docs.insert
        #         model:'loss'
        #         loss_id: loss._id
        #         loss_price: loss.price_per_serving
        #         buyer_id: Meteor.userId()
        #     Meteor.users.update Meteor.userId(),
        #         $inc:credit:-loss.price_per_serving
        #     Meteor.users.update loss._author_id,
        #         $inc:credit:loss.price_per_serving
        #     Meteor.call 'calc_loss_data', loss_id, ->


if Meteor.isServer
    Meteor.publish 'product_from_loss_id', (loss_id)->
        loss = Docs.findOne loss_id
        Docs.find
            model:'product'
            _id: loss.product_id


if Meteor.isClient
    Router.route '/loss/:doc_id/edit', (->
        @layout 'layout'
        @render 'loss_edit'
        ), name:'loss_edit'



    Template.loss_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'product', ->
        # @autorun => Meteor.subscribe 'model_docs', 'source'

    Template.loss_edit.onRendered ->
        # Meteor.setTimeout ->
        #     today = new Date()
        #     $('#availability')
        #         .calendar({
        #             inline:true
        #             # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
        #             # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
        #         })
        # , 2000

    Template.loss_edit.helpers
        balance_after_purchase: ->
            Meteor.user().points - @purchase_amount
        percent_difference: ->
            balance_after_purchase = 
                Meteor.user().points - @purchase_amount
            # difference
            @purchase_amount/Meteor.user().points
    Template.loss_edit.events
        'click .complete_loss': (e,t)->
            console.log @
            Session.set('lossing',true)
            if @purchase_amount
                if Meteor.user().points and @purchase_amount < Meteor.user().points
                    Meteor.call 'complete_loss', @_id, =>
                        Router.go "/product/#{@product_id}"
                        Session.set('lossing',false)
                else 
                    alert "not enough points"
                    Router.go "/user/#{Meteor.user().username}/points"
                    Session.set('lossing',false)
            else 
                alert 'no purchase amount'
            
            
        'click .delete_loss': ->
            Docs.remove @_id
            Router.go "/product/#{@product_id}"
