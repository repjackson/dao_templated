if Meteor.isClient
    Router.route '/tasks', (->
        @render 'tasks'
        ), name:'tasks'
    Router.route '/user/:username/tasks', (->
        @render 'user_tasks'
        ), name:'user_tasks'

    Template.tasks.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'task'
        # @autorun -> Meteor.subscribe 'tasks',
        #     Session.get('task_status_filter')
        # @autorun -> Meteor.subscribe 'model_docs', 'product', 20
        # @autorun -> Meteor.subscribe 'model_docs', 'thing', 100
    Template.tasks.events
        'click .add_task': ->
            new_id = 
                Docs.insert 
                    model:'task'
            Router.go "/task/#{new_id}/edit"



    Template.tasks.helpers
        tasks: ->
            match = {model:'task'}
            if Session.get('task_status_filter')
                match.status = Session.get('task_status_filter')
            if Session.get('task_delivery_filter')
                match.delivery_method = Session.get('task_sort_filter')
            if Session.get('task_sort_filter')
                match.delivery_method = Session.get('task_sort_filter')
            Docs.find match,
                sort: _timestamp:-1


if Meteor.isClient
    Router.route '/task/:doc_id', (->
        @layout 'layout'
        @render 'task_view'
        ), name:'task_view'


    Template.task_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'product_by_task_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'task_things', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'review_from_task_id', Router.current().params.doc_id


    Template.task_view.events
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
       
        'click .delete_task': ->
            thing_count = Docs.find(model:'thing').count()
            if confirm "delete? #{thing_count} things still"
                Docs.remove @_id
                Router.go "/tasks"
    
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
    Meteor.publish 'tasks', (task_id, status)->
        # task = Docs.findOne task_id
        match = {model:'task'}
        if status 
            match.status = status

        Docs.find match
        
    Meteor.publish 'review_from_task_id', (task_id)->
        # task = Docs.findOne task_id
        # match = {model:'task'}
        Docs.find 
            model:'task_review'
            task_id:task_id
        
    Meteor.publish 'product_by_task_id', (task_id)->
        task = Docs.findOne task_id
        Docs.find
            _id: task.product_id
    Meteor.publish 'task_things', (task_id)->
        task = Docs.findOne task_id
        Docs.find
            model:'thing'
            task_id: task_id

    # Meteor.methods
        # task_task: (task_id)->
        #     task = Docs.findOne task_id
        #     Docs.insert
        #         model:'task'
        #         task_id: task._id
        #         task_price: task.price_per_serving
        #         buyer_id: Meteor.userId()
        #     Meteor.users.update Meteor.userId(),
        #         $inc:credit:-task.price_per_serving
        #     Meteor.users.update task._author_id,
        #         $inc:credit:task.price_per_serving
        #     Meteor.call 'calc_task_data', task_id, ->


if Meteor.isServer
    Meteor.publish 'product_from_task_id', (task_id)->
        task = Docs.findOne task_id
        Docs.find
            model:'product'
            _id: task.product_id


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
        'click .complete_task': (e,t)->
            console.log @
            Session.set('tasking',true)
            if @purchase_amount
                if Meteor.user().points and @purchase_amount < Meteor.user().points
                    Meteor.call 'complete_task', @_id, =>
                        Router.go "/product/#{@product_id}"
                        Session.set('tasking',false)
                else 
                    alert "not enough points"
                    Router.go "/user/#{Meteor.user().username}/points"
                    Session.set('tasking',false)
            else 
                alert 'no purchase amount'
            
            
        'click .delete_task': ->
            Docs.remove @_id
            Router.go "/product/#{@product_id}"
