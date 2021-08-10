if Meteor.isClient
    Router.route '/menu', -> @render 'menu'
    
    Template.menu.onCreated ->
        @autorun => @subscribe 'model_docs', 'drink', ->
        @autorun => @subscribe 'model_docs', 'food', ->
    Template.menu.helpers
        drink_docs: ->
            Docs.find 
                model:'drink'
        food_docs: ->
            Docs.find 
                model:'food'
