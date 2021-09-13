if Meteor.isClient
    Router.route '/tasks', (->
        @render 'tasks'
        ), name:'tasks
        '

    Template.tasks.onCreated ->
        Session.setDefault('task_sort','views')
        @autorun -> Meteor.subscribe 'task',
            Session.get('task_title_filter')
            Session.get('task_view_filter')
            Session.get('task_sort')
            Session.get('task_sort_direction')
            
        # @autorun -> Meteor.subscribe 'model_docs', 'task', 20
        # @autorun -> Meteor.subscribe 'model_docs', 'thing', 100

    Template.tasks.helpers
        task_docs: ->
            match = {model:'task'}
            # if Session.get('task_status_filter')
            #     match.status = Session.get('task_status_filter')
            # if Session.get('task_delivery_filter')
            #     match.delivery_method = Session.get('task_sort_filter')
            # if Session.get('task_sort_filter')
            #     match.delivery_method = Session.get('order_sort_filter')
            Docs.find match,
                sort: 
                    "#{Session.get('task_sort')}":Session.get('task_sort_direction')

    Template.tasks.events
        'click .add_task': ->
            new_id = 
                Docs.insert 
                    model:'task'
                    _author_id:Meteor.userId()
                    _author_username:Meteor.user().username
                    _timestamp:Date.now()

            Router.go "/task/#{new_id}/edit"
            

if Meteor.isClient
    Router.route '/task/:doc_id', (->
        @layout 'layout'
        @render 'task_view'
        ), name:'task_view'

    Template.task_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
    Template.task_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
    Template.task_view.events
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
      
        'click .delete_task': ->
            thing_count = Docs.find(model:'thing').count()
            if confirm "delete? #{thing_count} things still"
                Docs.remove @_id
                Router.go "/task"
    
        'click .mark_ready': ->
            if confirm 'mark ready?'
                Docs.insert 
                    model:'task_event'
                    task_id: Router.current().params.doc_id
                    task_status:'ready'

        'click .add_review': ->
            Docs.insert 
                model:'task_review'
                task_id: Router.current().params.doc_id
                
                
        'click .review_positive': ->
            Docs.update @_id,
                $set:
                    rating:1
        'click .review_negative': ->
            Docs.update @_id,
                $set:
                    rating:-1

        'click .order_task': ->
            task = Docs.findOne Router.current().params.doc_id
            new_order_id = 
                Docs.insert 
                    model:'order'
                    parent_id:task._id
                    task_id:task._id
                    purchase_amount:task.price_dollars*100
                    task_title:task.title
            Router.go "/order/#{new_order_id}/edit"


    Template.task_view.helpers
        task_review: ->
            Docs.findOne 
                model:'task_review'
                task_id:Router.current().params.doc_id
    
        can_task: ->
            # if StripeCheckout
            unless @_author_id is Meteor.userId()
                task_count =
                    Docs.find(
                        model:'task'
                        task_id:@_id
                    ).count()
                if task_count is @servings_amount
                    false
                else
                    true
            # else
            #     false




if Meteor.isServer
    Meteor.publish 'task', (
        title_filter
        section
        sort_key
        sort_direction=-1
        )->
        # task = Docs.findOne task_id
        match = {model:'task'}
        # match.app = 'bc'
        if section 
            match.section = section
        if title_filter and title_filter.length > 1
            match.title = {$regex:title_filter, $options:'i'}

        Docs.find match,
            sort:"#{sort_key}":sort_direction
            limit:42
        
    Meteor.publish 'review_from_task_id', (task_id)->
        # task = Docs.findOne task_id
        # match = {model:'task'}
        Docs.find 
            model:'task_review'
            shop_id:shop_id
        
    Meteor.publish 'task_by_shop_id', (shop_id)->
        shop = Docs.findOne shop_id
        Docs.find
            _id: shop.task_id
    Meteor.publish 'shop_things', (shop_id)->
        shop = Docs.findOne shop_id
        Docs.find
            model:'thing'
            shop_id: shop_id

    # Meteor.methods
        # shop_shop: (shop_id)->
        #     shop = Docs.findOne shop_id
        #     Docs.insert
        #         model:'shop'
        #         shop_id: shop._id
        #         shop_price: shop.price_per_serving
        #         buyer_id: Meteor.userId()
        #     Meteor.users.update Meteor.userId(),
        #         $inc:credit:-shop.price_per_serving
        #     Meteor.users.update shop._author_id,
        #         $inc:credit:shop.price_per_serving
        #     Meteor.call 'calc_shop_data', shop_id, ->



# if Meteor.isClient
#     Template.user_shop_item.onCreated ->
#         # @autorun => Meteor.subscribe 'task_from_shop_id', @data._id
#     Template.user_shop.onCreated ->
#         @autorun => Meteor.subscribe 'user_shop', Router.current().params.username
#         @autorun => Meteor.subscribe 'model_docs', 'task'
#     Template.user_shop.helpers
#         shop: ->
#             current_user = Meteor.users.findOne username:Router.current().params.username
#             Docs.find {
#                 model:'shop'
#             }, sort:_timestamp:-1

if Meteor.isServer
    # Meteor.publish 'user_shop', (username)->
    #     # user = Meteor.users.findOne username:username
    #     Docs.find 
    #         model:'shop'
    #         _author_username:username
            
    
    Meteor.publish 'user_shop', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'shop'
            _author_id: user._id
        }, 
            limit:42
            sort:_timestamp:-1
            
    Meteor.publish 'task_from_shop_id', (shop_id)->
        shop = Docs.findOne shop_id
        Docs.find
            model:'task'
            _id: shop.task_id


if Meteor.isClient
    Router.route '/task/:doc_id/edit', (->
        @layout 'layout'
        @render 'task_edit'
        ), name:'task_edit'



    Template.task_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'source'

    Template.task_edit.onRendered ->
        # Meteor.setTimeout ->
        #     today = new Date()
        #     $('#availability')
        #         .calendar({
        #             inline:true
        #             # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
        #             # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
        #         })
        # , 2000

    Template.task_edit.helpers
        balance_after_purchase: ->
            Meteor.user().points - @purchase_amount
        percent_difference: ->
            balance_after_purchase = 
                Meteor.user().points - @purchase_amount
            # difference
            @purchase_amount/Meteor.user().points
    Template.task_edit.events
        'click .complete_shop': (e,t)->
            console.log @
            Session.set('shoping',true)
            if @purchase_amount
                if Meteor.user().points and @purchase_amount < Meteor.user().points
                    Meteor.call 'complete_shop', @_id, =>
                        Router.go "/task/#{@task_id}"
                        Session.set('shoping',false)
                else 
                    alert "not enough points"
                    Router.go "/user/#{Meteor.user().username}/points"
                    Session.set('shoping',false)
            else 
                alert 'no purchase amount'
            
            
        'click .delete_shop': ->
            if confirm "delete #{@title}?"
                Docs.remove @_id
                Router.go "/shop"


    # Template.linked_task.onCreated ->
    #     # console.log @data
    #     @autorun => Meteor.subscribe 'doc_by_id', @data.task_id, ->

    # Template.linked_task.helpers
    #     linked_task_doc: ->
    #         console.log @
    #         Docs.findOne @task_id
            
            
# if Meteor.isServer
    # Meteor.methods  
        # complete_shop: (shop_id)->
        #     console.log 'completing shop', shop_id
        #     current_shop = Docs.findOne shop_id            
        #     Docs.update shop_id, 
        #         $set:
        #             status:'purchased'
        #             purchased:true
        #             purchase_timestamp: Date.now()
        #     console.log 'marked complete'
        #     Meteor.call 'calc_user_points', @_author_id, ->