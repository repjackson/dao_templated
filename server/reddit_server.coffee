Meteor.publish 'subreddit_by_param', (subreddit)->
    Docs.find
        model:'subreddit'
        # "data.display_name":subreddit
        "name":subreddit

Meteor.publish 'sub_docs', (
    subreddit
    picked_tags
    picked_domains
    picked_time_tags
    picked_authors
    sort_key='data.created'
    sort_direction
    )->
    # @unblock()

    self = @
    match = {
        model:'rpost'
        subreddit:subreddit
    }
    # if view_bounties
    #     match.bounty = true
    # if view_unanswered
    #     match.is_answered = false
    # if picked_domains.length > 0 then match.domain = $all:picked_domains
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    # if picked_time_tags.length > 0 then match.time_tags = $all:picked_time_tags
    # if picked_authors.length > 0 then match.authors = $all:picked_authors
    console.log 'match', match
    console.log 'match', Docs.find(match).count()
    Docs.find match,
        limit:42
        sort: "#{sort_key}":parseInt(sort_direction)
        fields:
            title:1
            tags:1
            url:1
            model:1
            # data:1    
            "watson":1
            "data.domain":1
            "data.permalink":1
            "permalink":1
            "data.title":1
            "data.created":1
            "data.subreddit":1
            "data.url":1
            time_tags:1
            "data.url":1
            "data.is_reddit_media_domain":1
            'data.num_comments':1
            'data.author':1
            'data.ups':1
            "data.thumbnail":1
            "data.media.oembed":1
            analyzed_text:1
            "data":1
            permalink:1
            "data.media":1
            doc_sentiment_score:1
            subreddit:1
            doc_sentiment_label:1
            joy_percent:1
            sadness_percent:1
            fear_percent:1
            disgust_percent:1
            anger_percent:1
            "watson.metadata":1
            "data.thumbnail":1
            "data.url":1
            max_emotion_name:1
            max_emotion_percent:1
            



Meteor.publish 'agg_sentiment_subreddit', (
    subreddit
    picked_tags
    )->
    @unblock()
    self = @
    match = {
        model:'rpost'
        subreddit:subreddit
    }
        
    doc_count = Docs.find(match).count()
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    emotion_avgs = Docs.aggregate [
        { $match: match }
        #     # avgAmount: { $avg: { $multiply: [ "$price", "$quantity" ] } },
        { $group: 
            _id:null
            avg_sent_score: { $avg: "$doc_sentiment_score" }
            avg_joy_score: { $avg: "$joy_percent" }
            avg_anger_score: { $avg: "$anger_percent" }
            avg_sadness_score: { $avg: "$sadness_percent" }
            avg_disgust_score: { $avg: "$disgust_percent" }
            avg_fear_score: { $avg: "$fear_percent" }
        }
    ]
    emotion_avgs.forEach (res, i) ->
        self.added 'results', Random.id(),
            model:'emotion_avg'
            avg_sent_score: res.avg_sent_score
            avg_joy_score: res.avg_joy_score
            avg_anger_score: res.avg_anger_score
            avg_sadness_score: res.avg_sadness_score
            avg_disgust_score: res.avg_disgust_score
            avg_fear_score: res.avg_fear_score
    self.ready()
    

Meteor.publish 'sub_doc_count', (
    subreddit
    picked_tags
    picked_domains
    picked_time_tags
    )->
    @unblock()

    match = {model:'rpost'}
    match.subreddit = subreddit
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    if picked_domains.length > 0 then match.domain = $all:picked_domains
    if picked_time_tags.length > 0 then match.time_tags = $all:picked_time_tags
    Counts.publish this, 'sub_doc_counter', Docs.find(match)
    return undefined
Meteor.publish 'result_tags', (
    subreddit
    picked_tags
    picked_domains
    picked_time_tags
    # view_bounties
    # view_unanswered
    # query=''
    )->
    @unblock()
    self = @
    match = {
        model:'rpost'
        subreddit:subreddit
    }
    # if view_bounties
    #     match.bounty = true
    # if view_unanswered
    #     match.is_answered = false
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    if picked_domains.length > 0 then match.domain = $all:picked_domains
    if picked_time_tags.length > 0 then match.time_tags = $all:picked_time_tags
    # if picked_emotion.length > 0 then match.max_emotion_name = picked_emotion
    doc_count = Docs.find(match).count()
    console.log 'doc_count', doc_count
    console.log 'match', match
    subreddit_tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:20 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    subreddit_tag_cloud.forEach (tag, i) ->
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:'result_tag'
    
    
    domain_cloud = Docs.aggregate [
        { $match: match }
        { $project: "data.domain": 1 }
        # { $unwind: "$domain" }
        { $group: _id: "$data.domain", count: $sum: 1 }
        # { $match: _id: $nin: picked_domains }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:7 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    domain_cloud.forEach (domain, i) ->
        self.added 'results', Random.id(),
            name: domain.name
            count: domain.count
            model:'domain'
  
  
    
    time_tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "time_tags": 1 }
        { $unwind: "$time_tags" }
        { $group: _id: "$time_tags", count: $sum: 1 }
        # { $match: _id: $nin: picked_time_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:10 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    time_tag_cloud.forEach (time_tag, i) ->
        self.added 'results', Random.id(),
            name: time_tag.name
            count: time_tag.count
            model:'time_tag'
  
  
    # subreddit_Organization_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "Organization": 1 }
    #     { $unwind: "$Organization" }
    #     { $group: _id: "$Organization", count: $sum: 1 }
    #     # { $match: _id: $nin: picked_Organizations }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:5 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # subreddit_Organization_cloud.forEach (Organization, i) ->
    #     self.added 'results', Random.id(),
    #         name: Organization.name
    #         count: Organization.count
    #         model:'subreddit_Organization'
  
  
    # subreddit_Person_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "Person": 1 }
    #     { $unwind: "$Person" }
    #     { $group: _id: "$Person", count: $sum: 1 }
    #     # { $match: _id: $nin: picked_Persons }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:5 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # subreddit_Person_cloud.forEach (Person, i) ->
    #     self.added 'results', Random.id(),
    #         name: Person.name
    #         count: Person.count
    #         model:'subreddit_Person'
  
  
    # subreddit_Company_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "Company": 1 }
    #     { $unwind: "$Company" }
    #     { $group: _id: "$Company", count: $sum: 1 }
    #     # { $match: _id: $nin: picked_Companys }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:5 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # subreddit_Company_cloud.forEach (Company, i) ->
    #     self.added 'results', Random.id(),
    #         name: Company.name
    #         count: Company.count
    #         model:'subreddit_Company'
  
  
    # subreddit_emotion_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "max_emotion_name": 1 }
    #     { $group: _id: "$max_emotion_name", count: $sum: 1 }
    #     # { $match: _id: $nin: picked_emotions }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:5 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # subreddit_emotion_cloud.forEach (emotion, i) ->
    #     self.added 'results', Random.id(),
    #         name: emotion.name
    #         count: emotion.count
    #         model:'subreddit_emotion'
  
  
    self.ready()
    
    
Meteor.publish 'sub_count', (
    query=''
    picked_subtags
    nsfw
    )->
        
    match = {model:'subreddit'}
    
    # if nsfw
    #     match["data.over18"] = true
    # else 
    #     match["data.over18"] = false
    
    if picked_subtags.length > 0 then match.tags = $all:picked_subtags
    if query.length > 0
        match["data.display_name"] = {$regex:"#{query}", $options:'i'}
    Counts.publish this, 'sub_counter', Docs.find(match)
    return undefined


Meteor.publish 'subreddits', (
    query=''
    picked_subtags
    sort_key='data.subscribers'
    sort_direction=-1
    limit=20
    toggle
    nsfw
    )->
    # console.log limit
    match = {model:'subreddit'}
    
    # if nsfw
    #     match["data.over18"] = true
    # else 
    #     match["data.over18"] = false
    if picked_subtags.length > 0 then match.tags = $all:picked_subtags
    if query.length > 0
        match["data.display_name"] = {$regex:"#{query}", $options:'i'}
    # console.log 'match', match
    Docs.find match,
        limit:42
        sort: "#{sort_key}":sort_direction
        fields:
            model:1
            tags:1
            "data.display_name":1
            "data.title":1
            "data.primary_color":1
            "data.over18":1
            "data.header_title":1
            "data.created":1
            "data.header_img":1
            "data.public_description":1
            "data.advertiser_category":1
            "data.accounts_active":1
            "data.subscribers":1
            "data.banner_img":1
            "data.icon_img":1
        
        
    
Meteor.publish 'subreddit_tags', (
    picked_subtags
    toggle
    nsfw=false
    )->
    # @unblock()
    self = @
    match = {
        model:'subreddit'
    }
    # if nsfw
    #     match["data.over18"] = true
    # else 
    #     match["data.over18"] = false


    if picked_subtags.length > 0 then match.tags = $all:picked_subtags
    if picked_subtags.length > 0
        limit=10
    else 
        limit=25
    doc_count = Docs.find(match).count()
    # console.log 'doc_count', doc_count
    tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: picked_subtags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:limit }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    tag_cloud.forEach (tag, i) ->
        # console.log tag
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:'subreddit_tag'
    self.ready()


Meteor.publish 'subs_tags', (
    picked_tags
    picked_domains
    picked_authors
    # view_bounties
    # view_unanswered
    # query=''
    )->
    # @unblock()
    self = @
    match = {
        model:'subreddit'
        # subreddit:subreddit
    }
    # if view_bounties
    #     match.bounty = true
    # if view_unanswered
    #     match.is_answered = false
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    if picked_authors.length > 0 then match.author = $all:picked_authors
    # if picked_emotion.length > 0 then match.max_emotion_name = picked_emotion
    doc_count = Docs.find(match).count()
    sus_tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: picked_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:42 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    sus_tag_cloud.forEach (tag, i) ->
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:'subs_tag'
    
    
    subreddit_author_cloud = Docs.aggregate [
        { $match: match }
        { $project: "author": 1 }
        # { $unwind: "$author" }
        { $group: _id: "$author", count: $sum: 1 }
        # { $match: _id: $nin: picked_authors }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:7 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    subreddit_author_cloud.forEach (author, i) ->
        self.added 'results', Random.id(),
            name: author.name
            count: author.count
            model:'subreddit_author_tag'
  
    self.ready()


Meteor.methods    
    # search_subreddits: (search)->
    #     @unblock()
    #     HTTP.get "http://reddit.com/subreddits/search.json?q=#{search}&raw_json=1&nsfw=1", (err,res)->
    #         if res.data.data.dist > 1
    #             _.each(res.data.data.children[0..200], (item)=>
    #                 found = 
    #                     Docs.findOne    
    #                         model:'subreddit'
    #                         "data.display_name":item.data.display_name
    #                 # if found
    #                 unless found
    #                     item.model = 'subreddit'
    #                     Docs.insert item
    #             )
    search_subreddits: (search)->
        # console.log 'searching subs', search
        @unblock()
        HTTP.get "http://reddit.com/subreddits/search.json?q=#{search}&raw_json=1&nsfw=1&include_over_18=off&limit=10", (err,res)->
            if res.data.data.dist > 1
                _.each(res.data.data.children[0..100], (item)=>
                    # console.log item.data.display_name
                    added_tags = [search]
                    added_tags = _.flatten(added_tags)
                    # console.log 'added tags', added_tags
                    found = 
                        Docs.findOne    
                            model:'subreddit'
                            "data.display_name":item.data.display_name
                    if found
                        # console.log 'found', search, item.data.display_name
                        Docs.update found._id, 
                            $addToSet: tags: $each: added_tags
                    unless found
                        # console.log 'not found', item.data.display_name
                        item.model = 'subreddit'
                        item.tags = added_tags
                        Docs.insert item
                        
                )
        