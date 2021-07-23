if Meteor.isClient
    Template.tag_picker.onCreated ->
        @autorun => @subscribe 'wiki_doc', @data, ->
    Template.home.onCreated ->
        @autorun => @subscribe 'post_docs',
            picked_tags.array()
            Session.get('title_filter')
            # picked_authors.array()
            # picked_tasks.array()
            # picked_locations.array()
            # picked_timestamp_tags.array()
            # Session.get('view_videos')
            # Session.get('view_images')
            # Session.get('view_events')
            # Session.get('view_tasks')
            # Session.get('view_locations')
            # Session.get('view_food')
            # Session.get('sort_key')
            # Session.get('sort_direction')

        @autorun => @subscribe 'post_facets',
            picked_tags.array()
            Session.get('title_filter')
            # picked_authors.array()
            # picked_tasks.array()
            # picked_locations.array()
            # picked_timestamp_tags.array()
            # Session.get('view_videos')
            # Session.get('view_images')
            # Session.get('view_events')
            # Session.get('view_tasks')
            # Session.get('view_locations')
            # Session.get('view_food')
            # Session.get('sort_key')
            # Session.get('sort_direction')


    Template.tag_picker.events
        'click .pick_tag': -> 
            picked_tags.push @title
            # Meteor.call 'call_wiki', @title,=>
            #     console.log 'called wiki on', @title
    Template.home.events
        'click .unpick_tag': -> picked_tags.remove @valueOf()

    Template.tag_picker.helpers
        wiki_doc_flat: ->
            # console.log @valueOf()
            Docs.findOne 
                model:'wikipedia'
                title:@valueOf()
        wiki_doc: ->
            # console.log @valueOf()
            Docs.findOne 
                model:'wikipedia'
                title:@title
                
    Template.home.helpers        
        picked_tags: -> picked_tags.array()
    
        # post_docs: ->
        #     Docs.find 
        #         model:'post'
        tag_results: ->
            doc_count = Docs.find().count()
            console.log 'count', doc_count
            if doc_count > 1
                Results.find {
                    count:$lt:doc_count
                    model:'post_tag'
                }, sort:_timestamp:-1
            else
                Results.find {
                    model:'post_tag'
                }, sort:_timestamp:-1
  
                
        
        current_post: ->
            Docs.findOne
                _id:Session.get('viewing_post_id')
                
        home_items: ->
            Docs.find {
                model:'post'
            }, sort:_timestamp:-1
                
    Template.home_item.helpers
        card_class: ->
            if Session.equals('viewing_post_id', @_id) then 'inverted large' else 'small basic' 
        is_selected: ->
            Session.equals('viewing_post_id', @_id)
    Template.home_item.events
        'click .view_item': ->
            Session.set('viewing_post_id', @_id)
            Docs.update @_id, 
                $inc:views:1
    Template.home.events
        'click .add_post': ->
            new_id = Docs.insert 
                model:'post'
            Router.go "/post/#{new_id}/edit"    
    
                
        # 'keyup .new_message': (e,t)->
        #     if e.which is 13
        #         body = $('.new_message').val()
        #         Docs.insert 
        #             model:'post'
        #             title:body    
        #         body = $('.new_message').val('')
                        
            
if Meteor.isServer
    Meteor.publish 'chat_products', (chat_id)->
        Docs.find   
            model:'product'
            chat_ids:$in:[chat_id]
            
    Meteor.publish 'products_from_chat_id', (chat_id)->
        chat = Docs.findOne chat_id
        Docs.find   
            model:'product'
            chat_ids:$in:[chat_id]
            
    # Meteor.publish 'work_chat', (work_id)->
    #     work = Docs.findOne work_id
    #     Docs.find   
    #         model:'chat'
    #         _id: work.chat_id
            
            
    Meteor.publish 'user_liked_chats', (username)->
        Docs.find   
            model:'post'
            _id:$in:Meteor.user().liked_ids
            
            
if Meteor.isClient
    @picked_task_tags = new ReactiveArray []
    
    # Router.route '/task/:doc_id', (->
    #     @layout 'layout'
    #     @render 'task_view'
    #     ), name:'task_view'
                

            
    Template.task_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'task_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'location', ->
        @autorun => Meteor.subscribe 'child_groups_from_parent_id', Router.current().params.doc_id,->
 
    Template.task_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'task_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'location', ->
    


    Template.task_view.events
        'click .record_work': ->
            new_id = Docs.insert 
                model:'work'
                task_id: Router.current().params.doc_id
            Router.go "/work/#{new_id}/edit"    
    
                
           
    Template.task_view.helpers
        possible_locations: ->
            task = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'location'
                _id:$in:task.location_ids
                
        task_work: ->
            Docs.find 
                model:'work'
                task_id:Router.current().params.doc_id
                
    Template.task_edit.helpers
        task_locations: ->
            Docs.find
                model:'location'
                
        location_class: ->
            task = Docs.findOne Router.current().params.doc_id
            if task.location_ids and @_id in task.location_ids then 'blue' else 'basic'
            
                
    Template.task_edit.events
        'click .select_location': ->
            task = Docs.findOne Router.current().params.doc_id
            if task.location_ids and @_id in task.location_ids
                Docs.update Router.current().params.doc_id, 
                    $pull:location_ids:@_id
            else
                Docs.update Router.current().params.doc_id, 
                    $addToSet:location_ids:@_id
            
if Meteor.isServer
    Meteor.publish 'task_work', (task_id)->
        Docs.find   
            model:'work'
            task_id:task_id
    # Meteor.publish 'work_task', (work_id)->
    #     work = Docs.findOne work_id
    #     Docs.find   
    #         model:'task'
    #         _id: work.task_id
            
            
    Meteor.publish 'user_sent_task', (username)->
        Docs.find   
            model:'task'
            _author_username:username
    Meteor.publish 'product_task', (product_id)->
        Docs.find   
            model:'task'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/task/:doc_id/edit', (->
        @layout 'layout'
        @render 'task_edit'
        ), name:'task_edit'



    Template.task_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.task_edit.events
        'click .send_task': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    task = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update task._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'task sent',
                        ''
                        'success'
                    Router.go "/task/#{@_id}/"
                    )
            )

        'click .delete_task':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/tasks"
            
    Template.task_edit.helpers
        all_shop: ->
            Docs.find
                model:'task'


        current_subgroups: ->
            Docs.find 
                model:'group'
                parent_group_id:Meteor.user().current_group_id            