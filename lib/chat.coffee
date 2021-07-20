if Meteor.isClient
    Router.route '/chat', (->
        @layout 'layout'
        @render 'chats'
        ), name:'chats'
    
    Template.chats.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'chat', ->
        @autorun => Meteor.subscribe 'model_docs', 'chat_message', ->
            
            
    

    Template.chats.helpers
        chat_docs: ->
            Docs.find 
                model:'chat_message'
                
                
    Template.chats.events
        'keyup .new_message': (e,t)->
            if e.which is 13
                body = $('.new_message').val()
                console.log body
                Docs.insert 
                    model:'chat_message'
                    body:body    
                        
            
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
            model:'chat'
            _id:$in:Meteor.user().liked_ids