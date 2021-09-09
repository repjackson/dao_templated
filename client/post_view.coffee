Template.post_view.onRendered ->

Router.route '/post/:doc_id', (->
    @layout 'layout'
    @render 'post_view'
    ), name:'post_view'


Template.post_view.onRendered ->
    Meteor.call 'log_view', Router.current().params.doc_id, ->
Template.post_view.onCreated ->
    @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
    @autorun => Meteor.subscribe 'target_from_post_id', Router.current().params.doc_id
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'all_users'
    # @autorun => Meteor.subscribe 'product_by_post_id', Router.current().params.doc_id
    @autorun => Meteor.subscribe 'post_orders', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'review_from_post_id', Router.current().params.doc_id


Template.post_view.helpers  
    can_access: ->
        if @price is 0
            true
        else 
            found_order = 
                Docs.findOne 
                    post_id:Router.current().params.doc_id
                    _author_id:Meteor.userId()
            if found_order
                true
            else 
                false

    
    orders: ->
        post = Docs.findOne Router.current().params.doc_id
        # Meteor.users.find 
        #     _id: $in:post.buyer_ids
        Docs.find 
            model:'order'
            
            
            
Template.post_view.events
    'click .purchase': (e,t)->
        new_order = 
            Docs.insert     
                model:'order'
                _author_id:Meteor.userId()
                _author_username:Meteor.user().username
                _timestamp:Date.now()
                post_id:Router.current().params.doc_id
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
  