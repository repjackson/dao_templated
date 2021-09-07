Router.route '/', (->
    @render 'home'
    ), name:'home'

@picked_tags = new ReactiveArray []
@picked_authors = new ReactiveArray []
@picked_targets = new ReactiveArray []
@picked_timestamp_tags = new ReactiveArray []
@picked_location_tags = new ReactiveArray []


Template.leaderboard.onCreated ->
    @autorun -> Meteor.subscribe 'today_leaderboard', -> 


Template.tag_picker.onCreated ->
    @autorun => @subscribe 'ref_doc', @data, ->
Template.unpick_tag.onCreated ->
    @autorun => @subscribe 'flat_ref_doc', @data, ->
Template.flat_tag_picker.onCreated ->
    @autorun => @subscribe 'flat_ref_doc', @data, ->
Template.tag_picker.events
    'click .pick_tag': -> 
        picked_tags.push @title
        Session.set('viewing_post_id',null)
        # Meteor.call 'call_wiki', @title,=>
        #     console.log 'called wiki on', @title



Template.home.onCreated ->
    Session.setDefault('transfer_filter','day')
    @autorun -> Meteor.subscribe 'all_users', -> 
    @autorun -> Meteor.subscribe 'transfer_tags', 
        null
        'sent'
        picked_tags.array()
        picked_authors.array()
        picked_targets.array()
        picked_timestamp_tags.array()
        picked_location_tags.array()
        Session.get('transfer_filter')
        Session.get('transfer_sort_key')
        Session.get('transfer_sort_direction')
        , ->
    
    @autorun => Meteor.subscribe 'transfers', 
        null
        'sent'
        picked_tags.array()
        picked_authors.array()
        picked_targets.array()
        picked_timestamp_tags.array()
        picked_location_tags.array()
        Session.get('transfer_filter')
        Session.get('transfer_sort_key')
        Session.get('transfer_sort_direction')
        ,->

Template.home.helpers
    tag_results: -> Results.find(model:'tag')
    location_tag_results: -> Results.find(model:'location_tag')
    target_results: -> Results.find(model:'target_tag')
    author_results: -> Results.find(model:'author_tag')
    picked_tags: -> picked_tags.array()
    picked_authors: -> picked_authors.array()
    picked_targets: -> picked_targets.array()
    picked_location_tags: -> picked_location_tags.array()
    transfer_docs: ->
        match = {model:'transfer'}
        Docs.find match,
            sort: _timestamp:-1
Template.leaderboard.helpers
    most_sent_today: ->
        Meteor.users.find({total_sent_day: $gt:0},
            sort:
                total_sent_day:-1
        )
    most_received_today: ->
        Meteor.users.find({total_received_day: $gt:0},
            sort:
                total_received_day:-1
        )



Template.transfer_item.events
    'click .fly_right': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly up', 500)

Template.home.events
    # 'click .pick_tag': -> picked_tags.push @title
    'click .unpick_tag': -> picked_tags.remove @valueOf()
    'click #clear_tags': -> picked_tags.clear()
    
    'click .pick_location_tag': -> picked_location_tags.push @title
    'click .unpick_location_tag': -> picked_location_tags.remove @valueOf()
    
    'click .pick_target_tag': -> picked_targets.push @title
    'click .unpick_target_tag': -> picked_targets.remove @valueOf()
   
    'click .pick_author_tag': -> picked_authors.push @title
    'click .unpick_author_tag': -> picked_authors.remove @valueOf()
    # 'click #clear_tags': -> picked_tags.clear()
