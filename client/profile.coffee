Router.route '/user/:username', (->
    @layout 'user_layout'
    @render 'user_dashboard'
    ), name:'user_dashboard'


Template.user_layout.onCreated ->
    @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username, ->

Template.user_layout.onRendered ->
    Meteor.call 'calc_user_points', Router.current().params.username, ->
    Meteor.call 'log_profile_view', Router.current().params.username, ->
    # Meteor.call 'calc_user_tags', Router.current().params.username, ->
    # Meteor.setTimeout ->
    #     $('.button').popup()
    # , 2000

Template.user_layout.helpers
    user_from_username_param: -> Meteor.users.findOne username:Router.current().params.username
    user: -> Meteor.users.findOne username:Router.current().params.username

Template.user_layout.events
    'click .refresh_user_stats': ->
    'click .logout_other_clients': -> Meteor.logoutOtherClients()

    'click .logout': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly right', 1000)
        Meteor.logout()
        Router.go '/login'

        
Router.route '/user/:username/edit', -> @render 'user_edit'

Template.user_edit.onCreated ->
    @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username

Template.user_edit.onRendered ->
    # Meteor.setTimeout ->
    #     $('.button').popup()
    # , 2000
    
            
Router.route '/user/:username/sent', (->
    @layout 'profile_layout'
    @render 'user_sent'
    ), name:'user_sent'



Template.user_sent.onCreated ->
    @autorun => Meteor.subscribe 'transfers', 
        Router.current().params.username
        'sent'
        []
        []
        []
        []
        []
        ,->
    @autorun -> Meteor.subscribe 'transfer_tags', 
        Router.current().params.username
        'sent'
        []
        []
        []
        []
        []
        , ->
        
Template.user_received.onCreated ->
    @autorun => Meteor.subscribe 'transfers', 
        Router.current().params.username
        'received'
        []
        []
        []
        []
        []
        ,->
    @autorun -> Meteor.subscribe 'transfer_tags', 
        Router.current().params.username
        'received'
        []
        []
        []
        []
        []
        , ->
        
        
                
Template.user_sent.helpers
    sent_tags: ->
        Results.find(direction:'sent')
    user_sent_docs: ->
        user = Meteor.users.findOne username:Router.current().params.username
    
        Docs.find 
            model:'transfer'
            _author_username: user.username
            
    sent_items: ->
        current_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find {
            model:'transfer'
            _author_id: current_user._id
            # target_id: target_user._id
        },
            sort:_timestamp:-1
        
# Template.user_sent.events
#     'keyup .new_debit': (e,t)->
#         if e.which is 13
#             val = $('.new_debit').val()
#             console.log val
#             target_user = Meteor.users.findOne(username:Router.current().params.username)
#             Docs.insert
#                 model:'transfer'
#                 body: val
#                 target_id: target_user._id




Template.profile_picker.onCreated ->
    @autorun => @subscribe 'ref_doc', @data, ->


Template.profile_picker.events
    'click .pick_tag': (e,t)->
        picked_tags.clear()
        picked_tags.push @title
        $(e.currentTarget).closest('.grid').transition('fly right', 500)
        
        Router.go '/'

Template.user_received.helpers
    received_tags: ->
        Results.find(direction:'received')

    received_transfers: ->
        current_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find {
            model:'transfer'
            target_id: current_user._id
            # target_id: target_user._id
        },
            sort:_timestamp:-1



