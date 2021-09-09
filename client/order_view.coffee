Template.order_view.onRendered ->

Router.route '/order/:doc_id', (->
    @layout 'layout'
    @render 'order_view'
    ), name:'order_view'


Template.order_view.onRendered ->
    Meteor.call 'log_view', Router.current().params.doc_id, ->
Template.order_view.onCreated ->
    @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
    @autorun => Meteor.subscribe 'target_from_order_id', Router.current().params.doc_id
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'all_users'
    # @autorun => Meteor.subscribe 'product_by_order_id', Router.current().params.doc_id
    @autorun => Meteor.subscribe 'order_orders', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'review_from_order_id', Router.current().params.doc_id


Template.order_view.helpers  
    orders: ->
        order = Docs.findOne Router.current().params.doc_id
        # Meteor.users.find 
        #     _id: $in:order.buyer_ids
        Docs.find 
            model:'order'
            
            
            
Template.order_view.events
    'click .purchase': (e,t)->
        new_order = 
            Docs.insert     
                model:'order'
                _author_id:Meteor.userId()
                _author_username:Meteor.user().username
                _timestamp:Date.now()
                order_id:Router.current().params.doc_id
        Router.go "/order/#{new_order}/edit"
        
        
    'click .flat_tag': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly right', 500)
        # console.log @
        picked_tags.clear()
        picked_tags.push @valueOf()
        Router.go '/'
    # 'click .mark_viewed': ->
    #     # if confirm 'mark viewed?'
    #     Docs.update Router.current().params.doc_id, 
    #         $set:
    #             runner_viewed: true
    #             runner_viewed_timestamp: Date.now()
    #             runner_username: Meteor.user().username
    #             status: 'viewed' 
  