@picked_tags = new ReactiveArray []


Router.configure
	progressSpinner : false

Router.route '/', (->
    @render 'home'
    ), name:'home'

Template.right_sidebar.events
    'click .log_out': ->
        Meteor.logout()




Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'not_found'
    loadingTemplate: 'splash'
    trackPageView: false


$.cloudinary.config
    cloud_name:"facet"

        
Template.body.events
    'click .zoom_in_card': (e,t)->
        $(e.currentTarget).closest('.card').transition('drop', 500)
    'click .zoom_out': (e,t)->
        $(e.currentTarget).closest('.grid').transition('scale', 500)
    'click .fly_up': (e,t)->
        $(e.currentTarget).closest('.grid').transition('scale up', 500)
    'click .cards_up': (e,t)->
        $(e.currentTarget).closest('.cards').transition('scale up', 500)
    'click .fly_down': (e,t)->
        $(e.currentTarget).closest('.grid').transition('scale down', 500)
    'click .fly_right': (e,t)->
        $(e.currentTarget).closest('.grid').transition('scale right', 500)
    'click .fly_left': (e,t)->
        $(e.currentTarget).closest('.grid').transition('scale left', 500)


    "click a:not('.no_blink')": ->
        $('.global_container')
        .transition('fade out', 200)
        .transition('fade in', 200)

    'click .log_view': ->
        # console.log Template.currentData()
        # console.log @
        Docs.update @_id,
            $inc: views: 1


Router.route '*', -> @render 'home'


Template.home.helpers
    logging_in: -> Meteor.loggingIn()
    
    
# Template.home_item.onRendered ->
#     Meteor.call 'log_view', @data._id

        
Template.checkins.events
    'click .checkin': ->
        new_id = 
            Docs.insert
                model:'checkin'
        Router.go "/checkin/#{new_id}/edit"

Template.home_item.events
    'click .clear_current_post': ->
        Session.set('viewing_post_id',null)
        picked_tags.pop()
            
    
    'click .delete_post':->
        if confirm 'delete?'
            Docs.remove @_id
            Session.set('viewing_post_id',null)
    'click .save_post': -> Session.get('viewing_post_id', @_id)

