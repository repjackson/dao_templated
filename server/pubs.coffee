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
        
        
Meteor.publish 'user_model_docs', (username,model)->
    Docs.find 
        model:model
        _author_username:username
        
Meteor.publish 'user_groups', (username)->
    user = Meteor.users.findOne username:username
    Docs.find 
        model:'group'
        _id:$in:user.membership_group_ids



Meteor.publish 'parent_doc', (doc_id)->
    found = Docs.findOne doc_id
    Docs.find
        _id:found.parent_id
        
Meteor.publish 'all_users', (doc_id)->
    Meteor.users.find()

        
Meteor.publish 'doc_by_id', (doc_id)->
    Docs.find doc_id
Meteor.publish 'target_from_transfer_id', (transfer_id)->
    transfer = 
        Docs.findOne transfer_id
    Meteor.users.find transfer.target_id
    
    
Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id
Meteor.publish 'model_docs', (model)->
    Docs.find {
        model:model
        app:'bc'
    }, limit:20

Meteor.publish 'me', ()->
    Meteor.users.find Meteor.userId()

Meteor.publish 'user_from_username', (username)->
    Meteor.users.find username:username

Meteor.publish 'user_from_id', (user_id)->
    Meteor.users.find user_id

Meteor.publish 'author_from_doc_id', (doc_id)->
    doc = Docs.findOne doc_id
    if doc and doc._author_id
        Meteor.users.find doc._author_id

