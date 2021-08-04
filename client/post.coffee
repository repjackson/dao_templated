if Meteor.isClient
    Router.route '/posts', (->
        @render 'posts'
        ), name:'posts'

    Template.posts.onCreated ->
        @autorun -> Meteor.subscribe 'posts',
            Session.get('post_status_filter')
        # @autorun -> Meteor.subscribe 'model_docs', 'product', 20
        # @autorun -> Meteor.subscribe 'model_docs', 'thing', 100

    Template.posts.helpers
        posts: ->
            match = {model:'post'}
            if Session.get('post_status_filter')
                match.status = Session.get('post_status_filter')
            if Session.get('post_delivery_filter')
                match.delivery_method = Session.get('post_sort_filter')
            if Session.get('post_sort_filter')
                match.delivery_method = Session.get('post_sort_filter')
            Docs.find match,
                sort: _timestamp:-1


if Meteor.isClient
    Router.route '/post/:doc_id', (->
        @layout 'layout'
        @render 'post_view'
        ), name:'post_view'


    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'product_by_post_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'post_things', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'review_from_post_id', Router.current().params.doc_id


    Template.post_view.events
        'click .mark_viewed': ->
            # if confirm 'mark viewed?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    runner_viewed: true
                    runner_viewed_timestamp: Date.now()
                    runner_username: Meteor.user().username
                    status: 'viewed' 
      
        'click .mark_preparing': ->
            # if confirm 'mark mark_preparing?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    preparing: true
                    preparing_timestamp: Date.now()
                    status: 'preparing' 
       
        'click .mark_prepared': ->
            # if confirm 'mark prepared?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    prepared: true
                    prepared_timestamp: Date.now()
                    status: 'prepared' 
     
        'click .mark_arrived': ->
            # if confirm 'mark arrived?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    arrived: true
                    arrived_timestamp: Date.now()
                    status: 'arrived' 
        
        'click .mark_delivering': ->
            # if confirm 'mark delivering?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    delivering: true
                    delivering_timestamp: Date.now()
                    status: 'delivering' 
      
        'click .mark_delivered': ->
            # if confirm 'mark delivered?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    delivered: true
                    delivered_timestamp: Date.now()
                    status: 'delivered' 
      
        'click .delete_post': ->
            thing_count = Docs.find(model:'thing').count()
            if confirm "delete? #{thing_count} things still"
                Docs.remove @_id
                Router.go "/posts"
    
        'click .mark_ready': ->
            if confirm 'mark ready?'
                Docs.insert 
                    model:'post_event'
                    post_id: Router.current().params.doc_id
                    post_status:'ready'

        'click .add_review': ->
            Docs.insert 
                model:'post_review'
                post_id: Router.current().params.doc_id
                
                
        'click .review_positive': ->
            Docs.update @_id,
                $set:
                    rating:1
        'click .review_negative': ->
            Docs.update @_id,
                $set:
                    rating:-1

    Template.post_view.helpers
        post_review: ->
            Docs.findOne 
                model:'post_review'
                post_id:Router.current().params.doc_id
    
        can_post: ->
            # if StripeCheckout
            unless @_author_id is Meteor.userId()
                post_count =
                    Docs.find(
                        model:'post'
                        post_id:@_id
                    ).count()
                if post_count is @servings_amount
                    false
                else
                    true
            # else
            #     false




if Meteor.isServer
    Meteor.publish 'posts', (post_id, status)->
        # post = Docs.findOne post_id
        match = {model:'post'}
        if status 
            match.status = status

        Docs.find match
        
    Meteor.publish 'review_from_post_id', (post_id)->
        # post = Docs.findOne post_id
        # match = {model:'post'}
        Docs.find 
            model:'post_review'
            post_id:post_id
        
    Meteor.publish 'product_by_post_id', (post_id)->
        post = Docs.findOne post_id
        Docs.find
            _id: post.product_id
    Meteor.publish 'post_things', (post_id)->
        post = Docs.findOne post_id
        Docs.find
            model:'thing'
            post_id: post_id

    # Meteor.methods
        # post_post: (post_id)->
        #     post = Docs.findOne post_id
        #     Docs.insert
        #         model:'post'
        #         post_id: post._id
        #         post_price: post.price_per_serving
        #         buyer_id: Meteor.userId()
        #     Meteor.users.update Meteor.userId(),
        #         $inc:credit:-post.price_per_serving
        #     Meteor.users.update post._author_id,
        #         $inc:credit:post.price_per_serving
        #     Meteor.call 'calc_post_data', post_id, ->



if Meteor.isClient
    Template.user_post_item.onCreated ->
        # @autorun => Meteor.subscribe 'product_from_post_id', @data._id
    Template.user_posts.onCreated ->
        @autorun => Meteor.subscribe 'user_posts', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'product'
    Template.user_posts.helpers
        posts: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'post'
            }, sort:_timestamp:-1

if Meteor.isServer
    # Meteor.publish 'user_posts', (username)->
    #     # user = Meteor.users.findOne username:username
    #     Docs.find 
    #         model:'post'
    #         _author_username:username
            
    
    Meteor.publish 'user_posts', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'post'
            _author_id: user._id
        }, 
            limit:20
            sort:_timestamp:-1
            
    Meteor.publish 'product_from_post_id', (post_id)->
        post = Docs.findOne post_id
        Docs.find
            model:'product'
            _id: post.product_id


if Meteor.isClient
    Router.route '/post/:doc_id/edit', (->
        @layout 'layout'
        @render 'post_edit'
        ), name:'post_edit'



    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'source'

    Template.post_edit.onRendered ->
        # Meteor.setTimeout ->
        #     today = new Date()
        #     $('#availability')
        #         .calendar({
        #             inline:true
        #             # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
        #             # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
        #         })
        # , 2000

    Template.post_edit.helpers
        balance_after_purchase: ->
            Meteor.user().points - @purchase_amount
        percent_difference: ->
            balance_after_purchase = 
                Meteor.user().points - @purchase_amount
            # difference
            @purchase_amount/Meteor.user().points
    Template.post_edit.events
        'click .complete_post': (e,t)->
            console.log @
            Session.set('posting',true)
            if @purchase_amount
                if Meteor.user().points and @purchase_amount < Meteor.user().points
                    Meteor.call 'complete_post', @_id, =>
                        Router.go "/product/#{@product_id}"
                        Session.set('posting',false)
                else 
                    alert "not enough points"
                    Router.go "/user/#{Meteor.user().username}/points"
                    Session.set('posting',false)
            else 
                alert 'no purchase amount'
            
            
        'click .delete_post': ->
            Docs.remove @_id
            Router.go "/product/#{@product_id}"


    Template.linked_product.onCreated ->
        # console.log @data
        @autorun => Meteor.subscribe 'doc_by_id', @data.product_id, ->

    Template.linked_product.helpers
        linked_product_doc: ->
            console.log @
            Docs.findOne @product_id
            
            
if Meteor.isServer
    Meteor.methods  
        complete_post: (post_id)->
            console.log 'completing post', post_id
            current_post = Docs.findOne post_id            
            Docs.update post_id, 
                $set:
                    status:'purchased'
                    purchased:true
                    purchase_timestamp: Date.now()
            console.log 'marked complete'
            Meteor.call 'calc_user_points', @_author_id, ->