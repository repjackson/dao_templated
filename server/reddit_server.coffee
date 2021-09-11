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
        
        
        
Meteor.methods
    uniq: (doc_id)->
        @unblock()
        doc = Docs.findOne doc_id 
        # console.log 'tags', doc.tags
        flat = _.flatten(doc.tags)
        # console.log 'flat', doc.flat
        uniq = _.uniq(flat)
        # console.log 'uniq', uniq
        Docs.update doc._id,
            $set:
                tags:uniq

    find_subreddit: (title)->
        # return
        @unblock()
        console.log 'searching subreddit for', title
        # console.log 'type of query', typeof(query)
        # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
        HTTP.get "http://reddit.com/r/#{title}/about.json",(err,response)=>
            # console.log response
            # if err then console.log err
            # else if response.data.data.dist > 1
            #     # console.log 'found data'
            #     # console.log 'data length', response.data.data.children.length
            #     _.each(response.data.data.children, (item)=>
            found = Docs.findOne 
                model:'tribe'
                title:title
            unless found
                Docs.insert 
                    model:'tribe'
                    title:title
                    rd:response.data
            return
        return

    search_reddit: (query)->
        @unblock()
        # return
        console.log 'searching reddit for', query
        # console.log 'type of query', typeof(query)
        # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
        HTTP.get "http://reddit.com/search.json?q=#{query}&nsfw=1&limit=100&include_facets=false",(err,response)=>
            # console.log response.data
            if err then console.log err
            else if response.data.data.dist > 1
                # console.log 'found data'
                # console.log 'data length', response.data.data.children.length
                _.each(response.data.data.children, (item)=>
                    # console.log item.data
                    unless item.domain is "OneWordBan"
                        data = item.data
                        len = 200
                        # if typeof(query) is String
                        #     console.log 'is STRING'
                        #     added_tags = [query]
                        # else
                        added_tags = query
                        # added_tags = [query]
                        # console.log 'quer', query
                        # added_tags.push data.domain.toLowerCase()
                        # added_tags.push data.subreddit.toLowerCase()
                        # added_tags.push data.author.toLowerCase()
                        # console.log 'added_tags1', added_tags
                        flat = _.flatten(added_tags)
                        added_tags = _.uniq(flat)
                        # console.log 'added_tags2', added_tags
                        # console.log 'ups?', data.ups
                        reddit_post =
                            reddit_id: data.id
                            url: data.url
                            domain: data.domain
                            comment_count: data.num_comments
                            permalink: data.permalink
                            ups: data.ups
                            title: data.title
                            # root: query
                            # selftext: false
                            # thumbnail: false
                            tags: added_tags
                            model:'reddit'
                            # source:'reddit'
                        # console.log 'reddit post', reddit_post
                        existing_doc = Docs.findOne url:data.url
                        # if existing_doc
                            # if Meteor.isDevelopment
                                # console.log 'skipping existing url', data.url
                                # console.log 'adding', query, 'to tags'
                            # console.log 'type of tags', typeof(existing_doc.tags)
                            # if typeof(existing_doc.tags) is 'string'
                            #     # console.log 'unsetting tags because string', existing_doc.tags
                            #     Doc.update
                            #         $unset: tags: 1
                            # console.log 'existing ', reddit_post.title
                            # Docs.update existing_doc._id,
                            #     $addToSet: tags: $each: added_tags

                            # Meteor.call 'get_reddit_post', existing_doc._id, data.id, (err,res)->
                        unless existing_doc
                            # console.log 'importing url', data.url
                            new_reddit_post_id = Docs.insert reddit_post
                            # Meteor.users.update Meteor.userId(),
                            #     $inc:points:1
                            Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                            # console.log 'get post res', res
                    else
                        console.log 'NO found data'
                )

        # _.each(response.data.data.children, (item)->
        #     # data = item.data
        #     # len = 200
        #     console.log item.data
        # )

    reddit_all: ->
        total = 
            Docs.find({
                model:'reddit'
                subreddit: $exists:false
            }, limit:100)
        console.log 'total', total.count()
        total.forEach( (doc)->
        for doc in total.fetch()
            console.log doc._id
            Meteor.call 'get_reddit_post', doc._id, doc.reddit_id, ->
        )
        


    get_reddit_post: (doc_id, reddit_id, root)->
        @unblock()
        # console.log 'getting reddit post', doc_id, reddit_id
        doc = Docs.findOne doc_id
        if doc.reddit_id
            HTTP.get "http://reddit.com/by_id/t3_#{reddit_id}.json", (err,res)->
                if err then console.error err
                else
                    rd = res.data.data.children[0].data
                    # console.log rd
                    result =
                        Docs.update doc_id,
                            $set:
                                rd: rd
                    # console.log result
                    # if rd.is_video
                    #     # console.log 'pulling video comments watson'
                    #     Meteor.call 'call_watson', doc_id, 'url', 'video', ->
                    # else if rd.is_image
                    #     # console.log 'pulling image comments watson'
                    #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
                    # else
                    #     Meteor.call 'call_watson', doc_id, 'url', 'url', ->
                    #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
                    #     # Meteor.call 'call_visual', doc_id, ->
                    # if rd.selftext
                    #     unless rd.is_video
                    #         # if Meteor.isDevelopment
                    #         #     console.log "self text", rd.selftext
                    #         Docs.update doc_id, {
                    #             $set:
                    #                 body: rd.selftext
                    #         }, ->
                    #         #     Meteor.call 'pull_site', doc_id, url
                    #             # console.log 'hi'
                    # if rd.selftext_html
                    #     unless rd.is_video
                    #         Docs.update doc_id, {
                    #             $set:
                    #                 html: rd.selftext_html
                    #         }, ->
                    #             # Meteor.call 'pull_site', doc_id, url
                    #             # console.log 'hi'
                    # if rd.url
                    #     unless rd.is_video
                    #         url = rd.url
                    #         # if Meteor.isDevelopment
                    #         #     console.log "found url", url
                    #         Docs.update doc_id, {
                    #             $set:
                    #                 reddit_url: url
                    #                 url: url
                    #         }, ->
                    #             # Meteor.call 'call_watson', doc_id, 'url', 'url', ->
                    # update_ob = {}
                    # if rd.preview
                    #     if rd.preview.images[0].source.url
                    #         thumbnail = rd.preview.images[0].source.url
                    # else
                    #     thumbnail = rd.thumbnail
                    Docs.update doc_id,
                        $set:
                            rd: rd
                            url: rd.url
                            # reddit_image:rd.preview.images[0].source.url
                            thumbnail: rd.thumbnail
                            subreddit: rd.subreddit
                            author: rd.author
                            domain: rd.domain
                            is_video: rd.is_video
                            ups: rd.ups
                            # downs: rd.downs
                            over_18: rd.over_18
                        # $addToSet:
                        #     tags: $each: [rd.subreddit.toLowerCase()]
                    # console.log Docs.findOne(doc_id)
        else
            console.log 'no reddit id', doc        