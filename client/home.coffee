Router.route '/', (->
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
