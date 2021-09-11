Meteor.methods
    calc_sub_tags: (subreddit)->
        found = 
            Docs.findOne(
                model:'subreddit'
                "data.display_name": subreddit
            )
        sub_tags = Meteor.call 'agg_sub_tags', subreddit
        titles = _.pluck(sub_tags, 'title')
        if found
            Docs.update found._id, 
                $set:tags:titles
        Meteor.call 'clear_blocklist_doc', found._id, ->

    agg_sub_tags: (subreddit)->
        match = {model:'rpost', subreddit:subreddit}
        total_doc_result_count =
            Docs.find( match,
                {
                    fields:
                        _id:1
                }
            ).count()
        # limit=20
        options = {
            explain:false
            allowDiskUse:true
        }

        pipe =  [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ]

        if pipe
            agg = global['Docs'].rawCollection().aggregate(pipe,options)
            # else
            res = {}
            if agg
                agg.toArray()
                # omega = Docs.findOne model:'omega_session'
                # Docs.update omega._id,
                #     $set:
                #         agg:agg.toArray()
        else
            return null

        
        
        
    get_sub_info: (subreddit)->
        @unblock()
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        # url = "https://www.reddit.com/r/#{subreddit}/about.json?&raw_json=1&include_over_18=on"
        url = "https://www.reddit.com/r/#{subreddit}/about.json?&raw_json=1"
        HTTP.get url,(err,res)=>
            if res.data.data
                existing = Docs.findOne 
                    model:'subreddit'
                    name:subreddit
                    # "data.display_name":subreddit
                if existing
                    console.log 'existing', existing.title
                    # if Meteor.isDevelopment
                    # if typeof(existing.tags) is 'string'
                    #     Doc.update
                    #         $unset: tags: 1
                    Docs.update existing._id,
                        $set: data:res.data.data
                unless existing
                    sub = {}
                    sub.model = 'subreddit'
                    sub.name = subreddit
                    sub.data = res.data.data
                    console.log 'new', subreddit
                    new_reddit_post_id = Docs.insert sub
    
    get_sub_latest: (subreddit)->
        @unblock()
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "https://www.reddit.com/r/#{subreddit}.json?&raw_json=1&include_over_18=on&search_include_over_18=on&limit=100"
        HTTP.get url,(err,res)=>
            # if err
            # if res 
            # if res.data.data.dist > 1
            _.each(res.data.data.children[0..100], (item)=>
                found = 
                    Docs.findOne    
                        model:'rpost'
                        reddit_id:item.data.id
                        # subreddit:item.data.id
                if found
                    Docs.update found._id,
                        $set:subreddit:item.data.subreddit
                unless found
                    item.model = 'rpost'
                    item.reddit_id = item.data.id
                    item.author = item.data.author
                    item.subreddit = item.data.subreddit
                    # item.rdata = item.data
                    Docs.insert item
            )
            
    # get_sub_info: (subreddit)->
    #     @unblock()
    #     # if subreddit 
    #     #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
    #     # else
    #     url = "https://www.reddit.com/r/#{subreddit}/about.json?&raw_json=1"
    #     HTTP.get url,(err,res)=>
    #         # console.log res.data.data
    #         if res.data.data
    #             existing = Docs.findOne 
    #                 model:'subreddit'
    #                 "data.display_name":subreddit
    #             if existing
    #                 # console.log 'existing', existing
    #                 # if Meteor.isDevelopment
    #                 # if typeof(existing.tags) is 'string'
    #                 #     Doc.update
    #                 #         $unset: tags: 1
    #                 Docs.update existing._id,
    #                     $set: data:res.data.data
    #             unless existing
    #                 # console.log 'new sub', subreddit
    #                 sub = {}
    #                 sub.model = 'subreddit'
    #                 sub.name = subreddit
    #                 sub.data = res.data.data
    #                 new_reddit_post_id = Docs.insert sub
              
    search_subreddit: (subreddit,search)->
        @unblock()
        console.log 'searching', subreddit, search
        HTTP.get "http://reddit.com/r/#{subreddit}/search.json?q=#{search}&limit=100&restrict_sr=1&raw_json=1&include_over_18=off&nsfw=0", (err,res)->
            if res.data.data.dist > 1
                _.each(res.data.data.children[0..100], (item)=>
                    # for item in res.data.data.children[0..3]
                    id = item.data.id
                    # Docs.insert d
                    # found = 
                    added_tags = [search]
                    found = Docs.findOne({
                        model:'rpost',
                        # "data.subreddit":item.data.subreddit
                        subreddit:item.data.subreddit
                        reddit_id:id
                    })
                    #     # continue
                    if found
                        console.log 'updating', found.data.title
                        Docs.update({_id:found._id},{ 
                            $addToSet: tags: $each:added_tags
                            $set:
                                subreddit:item.data.subreddit
                        }, ->)
                    unless found
                        added_tags = _.flatten(search)
                        item.model = 'rpost'
                        item.reddit_id = item.data.id
                        item.author = item.data.author
                        item.subreddit = item.data.subreddit
                        item.tags = [search]
                        # item.rdata = item.data
                        Docs.insert item, ->
                )
                
                
    get_post_comments: (subreddit, doc_id)->
        @unblock()
        console.log 'getting post comments', subreddit, doc_id
        doc = Docs.findOne doc_id
        
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        # https://www.reddit.com/r/uwo/comments/fhnl8k/ontario_to_close_all_public_schools_for_two_weeks.json
        url = "https://www.reddit.com/r/#{subreddit}/comments/#{doc.reddit_id}.json?&raw_json=1&nsfw=1"
        HTTP.get url,(err,res)=>
            # console.log res.data.data.children.length
            # if res.data.data.dist > 1
            # [1].data.children[0].data.body
            _.each(res.data[1].data.children[0..100], (item)=>
                # console.log item
                found = 
                    Docs.findOne    
                        model:'rcomment'
                        reddit_id:item.data.id
                        parent_id:item.data.parent_id
                        # subreddit:item.data.id
                # if found
                #     console.log found, 'found comment'
                #     # Docs.update found._id,
                #     #     $set:subreddit:item.data.subreddit
                unless found
                    # console.log found, 'not found comment'
                    item.model = 'rcomment'
                    item.reddit_id = item.data.id
                    item.parent_id = item.data.parent_id
                    item.subreddit = subreddit
                    Docs.insert item
            )