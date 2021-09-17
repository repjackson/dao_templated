@picked_emotions = new ReactiveArray []
@picked_tags = new ReactiveArray []


Template.print_this.events
    'click .print_this': ->
        console.log @
        
        
Template.home.events
    'click .pick_tag': ->
        picked_tags.push @title
    'click .unpick_tag': ->
        picked_tags.remove @valueOf()
        
Template.home.helpers
    picked_tags: ->
        picked_tags.array()
    ten_tags: ->
        @tags[..10]
        
        

Template.remove_button.events
    'click .remove_this': ->
        if confirm "delete #{@title}?"
            console.log @
            Docs.remove @_id


$.cloudinary.config
    cloud_name:"facet"

        