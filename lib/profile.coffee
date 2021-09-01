if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'user_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
    
    
    Template.user_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username, ->
        # @autorun -> Meteor.subscribe 'user_groups', Router.current().params.username, ->
        @autorun -> Meteor.subscribe 'user_friends', Router.current().params.username, ->

    Template.user_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


if Meteor.isClient
    Template.user_layout.helpers
        user_from_username_param: -> Meteor.users.findOne username:Router.current().params.username
        user: -> Meteor.users.findOne username:Router.current().params.username

    Template.user_layout.events
        'click .logout_other_clients': -> Meteor.logoutOtherClients()

        'click .logout': (e,t)->
            $(e.currentTarget).closest('.grid').transition('fly right', 1000)
            Meteor.logout()
            Router.go '/login'

            
    Router.route '/user/:username/edit', -> @render 'user_edit'

    Template.user_edit.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username

    Template.user_edit.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000
        
                
if Meteor.isServer
    Meteor.publish 'user_model_docs', (username,model)->
        Docs.find 
            model:model
            _author_username:username
            
    Meteor.publish 'user_groups', (username)->
        user = Meteor.users.findOne username:username
        Docs.find 
            model:'group'
            _id:$in:user.membership_group_ids
            
    Meteor.methods 
        remove_friend_by_username: (username)->
            found = Meteor.users.findOne username:username
            Meteor.users.update Meteor.userId(),
                $pull:
                    friend_ids:found._id
                    friend_usernames:found.username
        
        add_friend_by_username: (username)->
            console.log 'adding username', username
            found = Meteor.users.findOne username:username
            if found 
                Meteor.users.update Meteor.userId(),
                    $addToSet:
                        friend_ids:found._id
                        friend_usernames:found.username
        search_by_username: (username)->
            found = Meteor.users.findOne 
                username:username
                
                
                
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
                            target_id:user._id
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
                    target_id: target_user._id



    Template.user_sent.helpers
        sent_items: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'transfer'
                _author_id: current_user._id
                # target_id: target_user._id
            },
                sort:_timestamp:-1



    Template.user_received.helpers
        received_transfers: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'transfer'
                target_id: current_user._id
                # target_id: target_user._id
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
            target_id: user._id
        }, 
            limit:100                