if Meteor.isClient
    Router.route '/user/:username/sent', (->
        @layout 'profile_layout'
        @render 'user_sent'
        ), name:'user_sent'



    Template.user_sent.onCreated ->
        @autorun => Meteor.subscribe 'user_sent', Router.current().params.username, ->
            
    Template.user_received.onCreated ->
        @autorun => Meteor.subscribe 'user_received', Router.current().params.username, ->
            
            
    Template.user_dashboard.events
        'click .send_points': ->
            Meteor.call 'insert_doc', {model:'transfer'}, (err,res)->
                console.log res
                # console.log 'new id', new_id
                user = Meteor.users.findOne username:Router.current().params.username
                        
                unless Meteor.user().username is Router.current().params.username
                    Docs.update res, 
                        $set:
                            target_username:Router.current().params.username
                            target_user_id:user._id
                Router.go "/transfer/#{res}/edit"
                    
    Template.user_sent.helpers
        user_sent_docs: ->
            user = Meteor.users.findOne username:Router.current().params.username
        
            Docs.find 
                model:'transfer'
                _author_username: user.username
                
            
    Template.user_sent.events
        'keyup .new_debit': (e,t)->
            if e.which is 13
                val = $('.new_debit').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'transfer'
                    body: val
                    target_user_id: target_user._id



    Template.user_sent.helpers
        sent_items: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'transfer'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1



    Template.user_received.helpers
        received_transfers: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'transfer'
                target_user_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1



if Meteor.isServer
    Meteor.publish 'user_sent', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'transfer'
            _author_id: user._id
        }, 
            limit:100    
            
    Meteor.publish 'user_received', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'transfer'
            target_user_id: user._id
        }, 
            limit:100