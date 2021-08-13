if Meteor.isClient
    Template.drinks.onCreated ->
        # @autorun => @subscribe 'model_docs', 'drink', ->
        @autorun -> Meteor.subscribe 'drinks',
            Session.get('food_title_filter')
    # Template.food.onCreated ->
    #     @autorun => @subscribe 'model_docs', 'food', ->
    Template.drinks.helpers
        drink_docs: ->
            Docs.find 
                model:'drink'
