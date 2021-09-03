Meteor.publish 'user_sent', (username)->
    user = Meteor.users.findOne username:username
    Docs.find {
        model:'transfer'
        _author_id: user._id
    }, 
        limit:100    
        
Meteor.publish 'transfers', (
    username
    direction
    picked_tags
    )->
        
    user = Meteor.users.findOne username:username
    match = {model:'transfer'}
    if picked_tags.length > 0 then match.tags = $all:picked_tags 
    if username
        if direction is 'sent'
            match._author_id = user._id
        if direction is 'received'
            match.target_id = user._id

    
    Docs.find match,
        limit:100                            
        

Meteor.publish 'transfer_tags', (
    username
    direction
    picked_tags
    title_filter
    )->
    self = @
    
    user = Meteor.users.findOne(username:username)
    
    # match = {}
    match = {}
    match.model = 'transfer'
    if username
        if direction is 'sent'
            match._author_id = user._id
        if direction is 'received'
            match.target_id = user._id

    
    if picked_tags.length > 0 then match.tags = $all:picked_tags 

    if title_filter and title_filter.length > 1
        match.title = {$regex:title_filter, $options:'i'}

    result_count = Docs.find(match).count()
    console.log 'transfer tag result count', result_count

    tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: picked_tags }
        { $match: count: $lt: result_count }
        # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
        { $sort: count: -1, _id: 1 }
        { $limit: 11 }
        { $project: _id: 0, title: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }
    
    tag_cloud.forEach (tag, i) =>
        self.added 'results', Random.id(),
            title: tag.title
            count: tag.count
            model:'tag'
            direction:direction
            # index: i

    self.ready()
    
        
        
        
        
        
Meteor.publish 'user_transfers', (username)->
    user = Meteor.users.findOne username:username
    Docs.find {
        model:'transfer'
        _author_id: user._id
    }, 
        limit:20
        sort:_timestamp:-1
        
        
        
        
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

