@picked_tags = new ReactiveArray []


Template.body.events
    'click .zoom_in_card': (e,t)->
        $(e.currentTarget).closest('.card').transition('drop', 500)
    'click .zoom_out': (e,t)->
        $(e.currentTarget).closest('.grid').transition('zoom', 500)
    'click .fly_up': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly up', 500)
    'click .cards_up': (e,t)->
        $(e.currentTarget).closest('.cards').transition('swing up', 500)
    'click .fly_down': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly down', 500)
    'click .fly_right': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly right', 500)
    'click .fly_left': (e,t)->
        console.log @, 'hi'
        $(e.currentTarget).closest('.grid').transition('fly left', 500)


if Meteor.isClient
    Template.nav.onCreated ->
        @autorun => Meteor.subscribe 'me'

# Router.configure
# 	progressSpinner : false

Router.route '/', (->
    @render 'home'
    ), name:'home'
Router.route '/add', (->
    @render 'add'
    ), name:'add'

Template.not_found.events
    'click .browser_back': ->
        window.history.back();


Template.add_column.events
    'click .add_doc': ->
        console.log @
        new_id = 
            Docs.insert 
                model:@model
        Router.go "/#{@model}/#{new_id}/edit"


Template.admin_footer.onCreated ->
    # @subscribe => 
    
Template.admin_footer.helpers
    docs: ->
        Docs.find()

    users: ->
        Meteor.users.find()
    results: ->
        Results.find()


Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'not_found'
    loadingTemplate: 'splash'
    trackPageView: true


$.cloudinary.config
    cloud_name:"facet"

        
Template.body.events
    'click .zoom_in_card': (e,t)->
        $(e.currentTarget).closest('.card').transition('drop', 500)
    'click .zoom_out': (e,t)->
        $(e.currentTarget).closest('.grid').transition('zoom', 500)
    'click .fly_up': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly up', 500)
    'click .cards_up': (e,t)->
        $(e.currentTarget).closest('.cards').transition('swing up', 500)
    'click .fly_down': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly down', 500)
    'click .fly_right': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly right', 500)
    'click .fly_left': (e,t)->
        console.log @, 'hi'
        $(e.currentTarget).closest('.grid').transition('fly left', 500)


    # "click a:not('.no_blink')": ->
    #     $('.global_container')
    #     .transition('fade out', 200)
    #     .transition('fade in', 200)

    'click .log_view': ->
        # console.log Template.currentData()
        # console.log @
        Docs.update @_id,
            $inc: views: 1


Router.route '*', -> @render 'home'

