if Meteor.isClient
    Router.route '/transfers', (->
        @render 'transfers'
        ), name:'transfers'

    Template.transfers.onCreated ->
        @autorun -> Meteor.subscribe 'transfers',
            Session.get('transfer_status_filter')
        # @autorun -> Meteor.subscribe 'model_docs', 'product', 20
        # @autorun -> Meteor.subscribe 'model_docs', 'thing', 100

    Template.transfers.helpers
        transfer_docs: ->
            match = {model:'transfer'}
            if Session.get('transfer_status_filter')
                match.status = Session.get('transfer_status_filter')
            if Session.get('transfer_delivery_filter')
                match.delivery_method = Session.get('transfer_sort_filter')
            if Session.get('transfer_sort_filter')
                match.delivery_method = Session.get('transfer_sort_filter')
            Docs.find match,
                sort: _timestamp:-1


if Meteor.isClient
    Router.route '/transfer/:doc_id', (->
        @layout 'layout'
        @render 'transfer_view'
        ), name:'transfer_view'


    Template.transfer_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'product_by_transfer_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'transfer_things', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'review_from_transfer_id', Router.current().params.doc_id


    Template.transfer_view.events
        # 'click .mark_viewed': ->
        #     # if confirm 'mark viewed?'
        #     Docs.update Router.current().params.doc_id, 
        #         $set:
        #             runner_viewed: true
        #             runner_viewed_timestamp: Date.now()
        #             runner_username: Meteor.user().username
        #             status: 'viewed' 
      

    Template.transfer_view.helpers
        transfer_review: ->
            Docs.findOne 
                model:'transfer_review'
                transfer_id:Router.current().params.doc_id
    
        can_transfer: ->
            # if StripeCheckout
            unless @_author_id is Meteor.userId()
                transfer_count =
                    Docs.find(
                        model:'transfer'
                        transfer_id:@_id
                    ).count()
                if transfer_count is @servings_amount
                    false
                else
                    true
            # else
            #     false




if Meteor.isServer
    Meteor.publish 'transfers', (transfer_id, status)->
        # transfer = Docs.findOne transfer_id
        match = {model:'transfer', app:'bc'}
        if status 
            match.status = status

        Docs.find match, 
            limit:20
        

if Meteor.isClient
    Template.user_transfer_item.onCreated ->
        # @autorun => Meteor.subscribe 'product_from_transfer_id', @data._id
    Template.user_transfers.onCreated ->
        @autorun => Meteor.subscribe 'user_transfers', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'product'
    Template.user_transfers.helpers
        transfers: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'transfer'
            }, sort:_timestamp:-1

if Meteor.isServer
    # Meteor.publish 'user_transfers', (username)->
    #     # user = Meteor.users.findOne username:username
    #     Docs.find 
    #         model:'transfer'
    #         _author_username:username
            
    
    Meteor.publish 'user_transfers', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'transfer'
            _author_id: user._id
        }, 
            limit:20
            sort:_timestamp:-1
            
    # Meteor.publish 'product_from_transfer_id', (transfer_id)->
    #     transfer = Docs.findOne transfer_id
    #     Docs.find
    #         model:'product'
    #         _id: transfer.product_id


if Meteor.isServer
    Meteor.methods  
        complete_transfer: (transfer_id)->
            console.log 'completing transfer', transfer_id
            current_transfer = Docs.findOne transfer_id            
            Docs.update transfer_id, 
                $set:
                    status:'purchased'
                    purchased:true
                    purchase_timestamp: Date.now()
            console.log 'marked complete'
            Meteor.call 'calc_user_points', @_author_id, ->
                
                
                
                
if Meteor.isClient
    Template.transfer_view.onCreated ->
        @autorun => Meteor.subscribe 'product_from_transfer_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
        
    Template.transfer_view.onRendered ->



if Meteor.isServer
    Meteor.publish 'product_from_transfer_id', (transfer_id)->
        transfer = Docs.findOne transfer_id
        Docs.find 
            _id:transfer.product_id



if Meteor.isServer
    Meteor.methods
        send_transfer: (transfer_id)->
            transfer = Docs.findOne transfer_id
            recipient = Meteor.users.findOne transfer.recipient_id
            transferer = Meteor.users.findOne transfer._author_id

            console.log 'sending transfer', transfer
            Meteor.call 'recalc_one_stats', recipient._id, ->
            Meteor.call 'recalc_one_stats', transfer._author_id, ->
    
            Docs.update transfer_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()
            return                