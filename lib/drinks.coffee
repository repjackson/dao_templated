if Meteor.isClient
    # Router.route '/drinks', -> @render 'drinks'
    Router.route '/drink/:doc_id', (->
        @layout 'layout'
        @render 'drink_view'
        ), name:'drink_view'


    Template.drink_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
    Template.drink_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->

    # Template.drinks.onCreated ->
    #     Session.setDefault('drink_sort_key', 'views')
    #     Session.setDefault('drink_sort_direction', -1)
    #     # @autorun => @subscribe 'model_docs', 'drink', ->
    #     @autorun -> Meteor.subscribe 'drinks',
    #         Session.get('food_title_filter')
    #         Session.get('drink_view_filter')
    #         Session.get('drink_sort_key')
    #         Session.get('drink_sort_direction')
    # # Template.food.onCreated ->
    #     @autorun => @subscribe 'model_docs', 'food', ->
    # Template.drinks.events
    #     'click .add_drink': ->
    #         new_id = 
    #             Docs.insert 
    #                 model:'drink'
    #         Router.go "/drink/#{new_id}/edit"
            
            
    # Template.drinks.helpers
    #     drink_docs: ->
    #         Docs.find {
    #             model:'drink'
    #         },
    #         sort:
    #             "#{Session.get('drink_sort_key')}":Session.get('drink_sort_direction')

if Meteor.isServer
    Meteor.publish 'drinks', (
        title_filter
        section_filter
        sort_key='views'
        sort_direction=-1
        )->
        # food = Docs.findOne food_id
        match = {model:'drink'}
        match.app = 'bc'
        if section_filter
            match.section = section_filter
        # match.section = $exists:false
        if title_filter and title_filter.length > 1
            match.title = {$regex:title_filter, $options:'i'}

        Docs.find match,
            sort:
                "#{sort_key}":sort_direction
    