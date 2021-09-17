@picked_emotions = new ReactiveArray []
@picked_tags = new ReactiveArray []


Template.print_this.events
    'click .print_this': ->
        console.log @

Template.remove_button.events
    'click .remove_this': ->
        if confirm "delete #{@title}?"
            console.log @
            Docs.remove @_id

Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'home'
    loadingTemplate: 'splash'
    trackPageView: true


$.cloudinary.config
    cloud_name:"facet"

        

Router.route '*', -> @render 'home'

