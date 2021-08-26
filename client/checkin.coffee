if Meteor.isClient
    Router.route '/checkins', (->
        @render 'checkins'
        ), name:'checkins'

    Template.checkins.onCreated ->
        @autorun -> Meteor.subscribe 'checkins',
            Session.get('checkin_status_filter')
        # @autorun -> Meteor.subscribe 'model_docs', 'product', 20
        # @autorun -> Meteor.subscribe 'model_docs', 'thing', 100

    Template.checkins.onCreated ->
        @autorun => @subscribe 'checked_in_users', ->
        @autorun => @subscribe 'checkins', ->
    Template.checkins.helpers
        checked_in_users: ->
            Meteor.users.find checkedin:true
        checkin_docs: ->
            Docs.find {
                model:'checkin'
            }, 
                sort:
                    _timestamp:-1
            
            
    Template.checkins.events
        'click .checkout': ->
            Meteor.users.update Meteor.userId(),
                $set:checkedin:false



    # Template.checkins.helpers
    #     checkins: ->
    #         match = {model:'checkin'}
    #         if Session.get('checkin_status_filter')
    #             match.status = Session.get('checkin_status_filter')
    #         if Session.get('checkin_delivery_filter')
    #             match.delivery_method = Session.get('checkin_sort_filter')
    #         if Session.get('checkin_sort_filter')
    #             match.delivery_method = Session.get('checkin_sort_filter')
    #         Docs.find match,
    #             sort: _timestamp:-1


if Meteor.isClient
    Router.route '/checkin/:doc_id', (->
        @layout 'layout'
        @render 'checkin_view'
        ), name:'checkin_view'


    Template.checkin_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id


    Template.checkin_view.events
        



if Meteor.isServer
    Meteor.publish 'checkins', (checkin_id, status)->
        # checkin = Docs.findOne checkin_id
        match = {model:'checkin'}
        if status 
            match.status = status

        Docs.find match
        
    # Meteor.publish 'review_from_checkin_id', (checkin_id)->
    #     # checkin = Docs.findOne checkin_id
    #     # match = {model:'checkin'}
    #     Docs.find 
    #         model:'checkin_review'
    #         checkin_id:checkin_id
        
    # Meteor.publish 'product_by_checkin_id', (checkin_id)->
    #     checkin = Docs.findOne checkin_id
    #     Docs.find
    #         _id: checkin.product_id
    # Meteor.publish 'checkin_things', (checkin_id)->
    #     checkin = Docs.findOne checkin_id
    #     Docs.find
    #         model:'thing'
    #         checkin_id: checkin_id

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
        upvote_class: -> if @checkin_vote and @checkin_vote is 1 then 'green' else 'outline grey'
        downvote_class: -> if @checkin_vote and @checkin_vote is -1 then 'red' else 'outline grey'
        # balance_after_purchase: ->
        #     Meteor.user().points - @purchase_amount
        # percent_difference: ->
        #     balance_after_purchase = 
        #         Meteor.user().points - @purchase_amount
        #     # difference
        #     @purchase_amount/Meteor.user().points
    Template.checkin_edit.events
        'click .upvote': ->
            Docs.update @_id,
                $set:
                    checkin_vote:1
    
        'click .downvote': ->
            Docs.update @_id,
                $set:
                    checkin_vote:-1
    
        'click .publish_anon': (e,t)->
            # console.log @
            Session.set('checking_in',true)
            Meteor.users.update Meteor.userId(),    
                $set:
                    checkedin:true
                    anon:true
            # Router.go "/user/#{Meteor.user().username}/"
            Router.go "/"
            Session.set('checking_in',false)
        'click .publish_public': (e,t)->
            # console.log @
            Session.set('checking_in',true)
            Meteor.users.update Meteor.userId(),    
                $set:
                    checkedin:true
                    anon:false
            # Router.go "/user/#{Meteor.user().username}/"
            Router.go "/"
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
            # console.log @
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