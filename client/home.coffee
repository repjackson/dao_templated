Router.route '/', (->
    @render 'transfers'
    ), name:'transfers'

@picked_transfer_tags = new ReactiveArray []
@picked_transfer_from = new ReactiveArray []
@picked_transfer_to = new ReactiveArray []
@picked_transfer_timestamp_tags = new ReactiveArray []
@picked_transfer_location_tags = new ReactiveArray []



Template.transfers.onCreated ->
    Session.setDefault('transfer_filter','now')
    @autorun -> Meteor.subscribe 'all_users', -> 
    @autorun -> Meteor.subscribe 'transfer_tags', 
        null
        'sent'
        picked_transfer_tags.array()
        picked_transfer_from.array()
        picked_transfer_to.array()
        picked_transfer_timestamp_tags.array()
        picked_transfer_location_tags.array()
        Session.get('transfer_filter')
        Session.get('transfer_sort_key')
        Session.get('transfer_sort_direction')
        , ->
    
    @autorun => Meteor.subscribe 'transfers', 
        null
        'sent'
        picked_transfer_tags.array()
        picked_transfer_from.array()
        picked_transfer_to.array()
        picked_transfer_timestamp_tags.array()
        picked_transfer_location_tags.array()
        Session.get('transfer_filter')
        Session.get('transfer_sort_key')
        Session.get('transfer_sort_direction')
        ,->

Template.transfers.helpers
    transfer_tags: ->
        Results.find(model:'tag')
    location_tag_results: ->
        Results.find(model:'location_tag')

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


Template.transfer_item.events
    'click .fly_right': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly up', 500)

Template.transfers.events
    'click .pick_tag': -> picked_transfer_tags.push @name
    'click .unpick_tag': -> picked_transfer_tags.remove @valueOf()
    'click #clear_tags': -> picked_transfer_tags.clear()
    
    'click .pick_location_tag': -> picked_transfer_tags.push @name
    'click .unpick_location_tag': -> picked_transfer_tags.remove @valueOf()
    'click #clear_tags': -> picked_transfer_tags.clear()
