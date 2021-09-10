Router.route '/order/:doc_id', (->
    @layout 'layout'
    @render 'order_view'
    ), name:'order_view'


Template.order_view.onRendered ->
    Meteor.call 'log_view', Router.current().params.doc_id, ->
Template.order_view.onCreated ->
    console.log @
    @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->


Template.order_view.helpers  
            
Template.order_view.events