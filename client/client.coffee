@picked_emotions = new ReactiveArray []
@picked_tags = new ReactiveArray []


Template.print_this.events
    'click .print_this': ->
        console.log @
        
        
Template.home.helpers
    ten_tags: ->
        @tags[..10]
        
        

Template.remove_button.events
    'click .remove_this': ->
        if confirm "delete #{@title}?"
            console.log @
            Docs.remove @_id


$.cloudinary.config
    cloud_name:"facet"

        