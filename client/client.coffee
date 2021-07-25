@picked_tags = new ReactiveArray []



$.cloudinary.config
    cloud_name:"facet"

        
Template.body.events
    'click .zoom_in_card': (e,t)->
        $(e.currentTarget).closest('.column').transition('drop', 1000)
    'click .zoom_out': (e,t)->
        $(e.currentTarget).closest('.grid').transition('scale', 1000)
    'click .fly_up': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly up', 1000)
    'click .fly_down': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly down', 1000)
    'click .fly_right': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly right', 1000)
    'click .fly_left': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly left', 1000)


    "click a:not('.no_blink')": ->
        $('.global_container')
        .transition('fade out', 200)
        .transition('fade in', 200)

    'click .log_view': ->
        # console.log Template.currentData()
        # console.log @
        Docs.update @_id,
            $inc: views: 1


Template.home.helpers
    logging_in: -> Meteor.loggingIn()
    
    
Template.post_view.onRendered ->
    Meteor.call 'log_view', @data._id

        


Template.post_view.events
    'click .clear_current_post': ->
        Session.set('viewing_post_id',null)
            
    
    'click .delete_post':->
        if confirm 'delete?'
            Docs.remove @_id
            Session.set('viewing_post_id',null)
    'click .save_post': -> Session.get('viewing_post_id', @_id)
