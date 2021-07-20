if Meteor.isClient
    Template.home.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'chat', ->
        # @autorun => Meteor.subscribe 'model_docs', 'post', ->
            
        @autorun => @subscribe 'post_docs',
            picked_post_tags.array()
            Session.get('post_title_filter')

        @autorun => @subscribe 'post_facets',
            picked_post_tags.array()
            Session.get('post_title_filter')

    

    

    Template.home.helpers
        home_items: ->
            Docs.find {
                model:'post'
            }, sort:_timestamp:-1
                
    Template.home.events
        'click .add_post': ->
            new_id = Docs.insert 
                model:'post'
            Router.go "/post/#{new_id}/edit"    
    
        'keyup .new_message': (e,t)->
            if e.which is 13
                body = $('.new_message').val()
                Docs.insert 
                    model:'post'
                    title:body    
                body = $('.new_message').val('')
                        
            
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