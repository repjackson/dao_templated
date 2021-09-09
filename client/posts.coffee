Router.route '/posts', (->
    @render 'posts'
    ), name:'posts'

@picked_tags = new ReactiveArray []
@picked_authors = new ReactiveArray []
@picked_targets = new ReactiveArray []
@picked_timestamp_tags = new ReactiveArray []
@picked_location_tags = new ReactiveArray []




Template.posts.onCreated ->
    Session.setDefault('post_filter','all')
    @autorun -> Meteor.subscribe 'all_users', -> 
    @autorun -> Meteor.subscribe 'post_tags', 
        null
        'sent'
        picked_tags.array()
        picked_authors.array()
        picked_targets.array()
        picked_timestamp_tags.array()
        picked_location_tags.array()
        Session.get('post_filter')
        Session.get('post_sort_key')
        Session.get('post_sort_direction')
        , ->
    
    @autorun => Meteor.subscribe 'posts', 
        null
        'sent'
        picked_tags.array()
        picked_authors.array()
        picked_targets.array()
        picked_timestamp_tags.array()
        picked_location_tags.array()
        Session.get('post_filter')
        Session.get('post_sort_key')
        Session.get('post_sort_direction')
        ,->

Template.posts.helpers
    tag_results: -> Results.find(model:'tag')
    location_tag_results: -> Results.find(model:'location_tag')
    target_results: -> Results.find(model:'target_tag')
    author_results: -> Results.find(model:'author_tag')
    picked_tags: -> picked_tags.array()
    picked_authors: -> picked_authors.array()
    picked_targets: -> picked_targets.array()
    picked_location_tags: -> picked_location_tags.array()
    post_docs: ->
        match = {model:'post'}
        if picked_tags.array().length > 0
            match.tags = $all: picked_tags.array()
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



Template.post_item.events
    'click .fly_right': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly right', 250)

Template.posts.events
    'click .add_post': ->
        new_id = 
            Docs.insert 
                model:'post'
        Router.go "/post/#{new_id}/edit"   
        
        
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
