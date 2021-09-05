Router.route '/', (->
    @render 'transfers'
    ), name:'transfers'

Template.transfers.onCreated ->
    @autorun -> Meteor.subscribe 'all_users', -> 
    @autorun -> Meteor.subscribe 'transfer_tags', 
        null
        'sent'
        picked_tags.array()
        , ->
    
    @autorun => Meteor.subscribe 'transfers', 
        null
        'sent'
        picked_tags.array()
        ,->

Template.transfers.helpers
    transfer_tags: ->
        Results.find()

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
