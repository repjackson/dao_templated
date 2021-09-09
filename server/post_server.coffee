Meteor.publish 'posts', (
    username
    direction
    picked_tags
    picked_authors
    picked_targets
    picked_timestamp_tags
    picked_location_tags
    filter=null
    sort_key='_timestamp'
    sort_direction=-1
    )->
        
    user = Meteor.users.findOne username:username
    match = {model:'post'}
    
    if filter is 'now'
        now = Date.now()
        gap = 60*60*1000
        hour_ago = now-gap
        match._timestamp = $gte:hour_ago
    else if filter is 'today'
        now = Date.now()
        gap = 60*60*1000*24
        day_ago = now-gap
        match._timestamp = $gte:day_ago
    
    if picked_tags.length > 0 then match.tags = $all:picked_tags 
    if picked_location_tags.length > 0 then match.location_tags = $all:picked_location_tags 
    if picked_timestamp_tags.length > 0 then match._timestamp_tags = $all:picked_timestamp_tags 
    if picked_authors.length > 0 then match._author_username = $all:picked_authors 
    if picked_targets.length > 0 then match.target_username = $all:picked_targets 
    
    if username
        if direction is 'sent'
            match._author_id = user._id
        if direction is 'received'
            match.target_id = user._id

    
    Docs.find match,
        limit:20   
        sort:
            "#{sort_key}":sort_direction
        


Meteor.publish 'post_orders', (post_id)->
    Docs.find 
        model:'order'
        post_id:post_id
Meteor.publish 'post_tags', (
    username
    direction
    picked_tags
    picked_authors
    picked_targets
    picked_timestamp_tags
    picked_location_tags
    # title_filter=null
    filter=null
    sort_key='_timestamp'
    sort_direction=-1
    )->
    self = @
    
    user = Meteor.users.findOne(username:username)
    
    # match = {}
    match = {}
    match.model = 'post'
    
    if filter is 'now'
        now = Date.now()
        gap = 60*60*1000
        hour_ago = now-gap
        match._timestamp = $gte:hour_ago
    else if filter is 'today'
        now = Date.now()
        gap = 60*60*24*1000
        day_ago = now-gap
        match._timestamp = $gte:day_ago

    
    if username
        if direction is 'sent'
            match._author_id = user._id
        if direction is 'received'
            match.target_id = user._id

    
    if picked_tags.length > 0 then match.tags = $all:picked_tags 

    if picked_location_tags.length > 0 then match.location_tags = $all:picked_location_tags 
    if picked_timestamp_tags.length > 0 then match._timestamp_tags = $all:picked_timestamp_tags 
    if picked_authors.length > 0 then match._author_username = $all:picked_authors 
    if picked_targets.length > 0 then match.target_username = $all:picked_targets 



    # if title_filter and title_filter.length > 1
    #     match.title = {$regex:title_filter, $options:'i'}

    result_count = Docs.find(match).count()

    tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: picked_tags }
        { $match: count: $lt: result_count }
        # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
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
            
            
    location_cloud = Docs.aggregate [
        { $match: match }
        { $project: "location_tags": 1 }
        { $unwind: "$location_tags" }
        { $group: _id: "$location_tags", count: $sum: 1 }
        { $match: _id: $nin: picked_location_tags }
        { $match: count: $lt: result_count }
        # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, title: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }
    
    location_cloud.forEach (tag, i) =>
        self.added 'results', Random.id(),
            title: tag.title
            count: tag.count
            model:'location_tag'
            # index: i
            
    target_cloud = Docs.aggregate [
        { $match: match }
        { $project: "target_username": 1 }
        { $unwind: "$target_username" }
        { $group: _id: "$target_username", count: $sum: 1 }
        { $match: _id: $nin: picked_targets }
        { $match: count: $lt: result_count }
        # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, title: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }
    
    target_cloud.forEach (tag, i) =>
        self.added 'results', Random.id(),
            title: tag.title
            count: tag.count
            model:'target_tag'
            # index: i
            
            
    author_cloud = Docs.aggregate [
        { $match: match }
        { $project: "_author_username": 1 }
        { $unwind: "$_author_username" }
        { $group: _id: "$_author_username", count: $sum: 1 }
        { $match: _id: $nin: picked_authors }
        { $match: count: $lt: result_count }
        # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, title: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }
    
    author_cloud.forEach (tag, i) =>
        self.added 'results', Random.id(),
            title: tag.title
            count: tag.count
            model:'author_tag'
            # index: i
            
    # from_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "_author_username": 1 }
    #     { $unwind: "$_author_username" }
    #     { $group: _id: "$_author_username", count: $sum: 1 }
    #     { $match: _id: $nin: picked_authors }
    #     { $match: count: $lt: result_count }
    #     # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
    #     { $sort: count: -1, _id: 1 }
    #     { $limit: 20 }
    #     { $project: _id: 0, title: '$_id', count: 1 }
    # ], {
    #     allowDiskUse: true
    # }
    
    # tag_cloud.forEach (tag, i) =>
    #     self.added 'results', Random.id(),
    #         title: tag.title
    #         count: tag.count
    #         model:'from'
    #         # index: i

    self.ready()
    
        
        


Meteor.methods 
    confirm_order:(order_id)->
        order = Docs.findOne order_id
        post = Docs.findOne order.post_id
        
        user = Meteor.user()
        
        console.log 'user points', user.points
        console.log 'post price', post.price
        if user.points <= post.price
            console.log 'not enough', user.points-post.price
            throw new Meteor.Error 'not enough points'
        else 
            Docs.update order_id, 
                $set:
                    complete: true
                    order_price:post.price
                    
            
                    