Template.nav.events
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
        # console.log @, 'hi'
        $(e.currentTarget).closest('.grid').transition('fly left', 500)


if Meteor.isClient
    Template.nav.onCreated ->
        @autorun => Meteor.subscribe 'me'


Template.nav.events
    'click .send_points': ->
        if Meteor.userId()
            Meteor.call 'insert_doc', {model:'transfer', privacy:'private'}, (err,res)->
                # console.log res
                # console.log 'new id', new_id
                user = Meteor.users.findOne username:Router.current().params.username
                if user 
                    unless Meteor.user().username is Router.current().params.username
                        Docs.update res, 
                            $set:
                                target_username:Router.current().params.username
                                target_id:user._id
                Router.go "/transfer/#{res}/edit"
        else 
            Router.go "/login"
        
# Router.configure
# 	progressSpinner : false


Template.not_found.events
    'click .browser_back': ->
        window.history.back();



Template.admin_footer.onCreated ->
    # @subscribe => 
    
Template.admin_footer.events
    'click .delete_user': ->
        if confirm "delete #{@} user?"
            Meteor.users.remove @_id
    
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

        

Router.route '*', -> @render 'home'

