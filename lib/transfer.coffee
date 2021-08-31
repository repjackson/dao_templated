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
                
    Meteor.methods
        send_transfer: (transfer_id)->
            transfer = Docs.findOne transfer_id
            recipient = Meteor.users.findOne transfer.target_user_id
            transferer = Meteor.users.findOne transfer._author_id

            console.log 'sending transfer', transfer
            Meteor.call 'recalc_one_stats', recipient._id, ->
            Meteor.call 'recalc_one_stats', transfer._author_id, ->
    
            Docs.update transfer_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()
            return                