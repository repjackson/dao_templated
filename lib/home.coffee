if Meteor.isClient
    # Template.home.onCreated ->
    #     @autorun => @subscribe 'model_docs', 'order', ->
    Router.route '/', (->
        @render 'home'
        ), name:'home'
    Template.registerHelper 'skip_is_zero', ()-> Session.equals('skip', 0)
    Template.registerHelper 'one_post', ()-> Counts.get('result_counter') is 1
    Template.registerHelper 'two_posts', ()-> Counts.get('result_counter') is 2
    Template.registerHelper 'seven_tags', ()-> @tags[..7]
    Template.registerHelper 'key_value', (key,value)-> @["#{key}"] is value
            
            
            
            
    # Template.losses.onCreated ->
    #     @autorun => @subscribe 'model_docs', 'loss', ->
    # Template.losses.helpers
    #     loss_docs: ->
    #         Docs.find 
    #             model:'loss'
    Template.latest_posts.onCreated ->
        @autorun => @subscribe 'latest_posts', ->
    Template.latest_tasks.onCreated ->
        @autorun => @subscribe 'latest_tasks', ->
  
    Template.latest_posts.helpers
        latest_post_docs: ->
            Docs.find({
                model:'post'
            }, {
                sort:_timestamp:-1
                limit:10
            })
    Template.latest_tasks.helpers
        latest_task_docs: ->
            Docs.find({
                model:'task'
            }, {
                sort:
                    _timestamp:-1
                limit:10
            })
  
if Meteor.isServer
    Meteor.publish 'latest_posts', ->
        Docs.find({
            model:'post'
        }, {
            sort:
                _timestamp:-1
            limit:10
        })    
    Meteor.publish 'latest_tasks', ->
        Docs.find({
            model:'task'
        }, {
            sort:_timestamp:-1
            limit:10
        })    
            
if Meteor.isClient
  
    Template.tag_picker.onCreated ->
        @autorun => @subscribe 'ref_doc', @data, ->
    Template.unpick_tag.onCreated ->
        @autorun => @subscribe 'flat_ref_doc', @data, ->
            
            
    Template.daily_question.onCreated ->
        @autorun => @subscribe('daily_question')
        
        
        
        
        
        
        
    Template.home.onCreated ->
        @autorun => @subscribe('doc_by_id',Session.get('viewing_post_id'))
        @autorun => @subscribe 'post_docs',
            picked_tags.array()
            Session.get('title_filter')
    
        @autorun => @subscribe 'post_facets',
            picked_tags.array()
            Session.get('title_filter')

        Session.setDefault('skip',0)
        Session.setDefault('view_section','content')
        @autorun -> Meteor.subscribe('alpha_combo',picked_tags.array())
        # @autorun -> Meteor.subscribe('alpha_single',picked_tags.array())
        @autorun -> Meteor.subscribe('duck',picked_tags.array())
        @autorun -> Meteor.subscribe('doc_count',
            picked_tags.array()
            Session.get('view_mode')
            Session.get('emotion_mode')
            # picked_models.array()
            # picked_subreddits.array()
            picked_emotions.array()
            )
        @autorun => Meteor.subscribe('dtags',
            picked_tags.array()
            Session.get('view_mode')
            Session.get('emotion_mode')
            Session.get('toggle')
            # picked_models.array()
            # picked_subreddits.array()
            picked_emotions.array()
            # Session.get('query')
            )
        @autorun => Meteor.subscribe('docs',
            picked_tags.array()
            Session.get('view_mode')
            Session.get('emotion_mode')
            Session.get('toggle')
            # picked_models.array()
            # picked_subreddits.array()
            picked_emotions.array()
            # Session.get('query')
            Session.get('skip')
            )


    
    Template.tag_picker.events
        'click .pick_tag': -> 
            picked_tags.push @title
            Session.set('viewing_post_id',null)
            # Meteor.call 'call_wiki', @title,=>
            #     console.log 'called wiki on', @title
    
    
    Template.duck.events
        'click .topic': (e,t)-> 
            console.log @
            window.speechSynthesis.speak new SpeechSynthesisUtterance @Text
            # console.log @FirstURL.replace(/\s+/g, '-')
            url = new URL(@FirstURL);
            console.log url
            console.log url.pathname
            picked_tags.push @Text.toLowerCase()
            Meteor.call 'call_wiki', picked_tags.array().toString(), ->
            Meteor.call 'search_reddit', picked_tags.array(), ->
    
        'click .abstract': (e,t)-> 
            console.log @
            window.speechSynthesis.speak new SpeechSynthesisUtterance @AbstractText
    
        # 'click .tagger': (e,t)->
        #     Meteor.call 'call_watson', @_id, 'url', 'url', ->
    
    
    
    Template.home.helpers
        one_doc: ->
            count = 
                Docs.find(
                    model:'post'
                    tags:$in:picked_tags.array()
                ).count()
            # console.log 'count', count
            count is 1
            
            
        alphas: ->
            Docs.find 
                model:'alpha'
                # query: $in: picked_tags.array()
                query: picked_tags.array().toString()
        # alpha_singles: ->
        #     Docs.find 
        #         model:'alpha'
        #         query: $in: picked_tags.array()
        #         # query: picked_tags.array().toString()
        ducks: ->
            Docs.find 
                model:'duck'
                # query: $in: picked_tags.array()
                query: picked_tags.array().toString()
        many_tags: -> picked_tags.array().length > 1
        doc_count: -> Counts.get('result_counter')
            
            
    Template.home_item.helpers
        one_doc: ->
            count = 
                Docs.find(
                    model:'post'
                    tags:$in:picked_tags.array()
                ).count()
            # console.log 'count', count
            count is 1
        two_doc: ->
            count = 
                Docs.find(
                    model:'post'
                    tags:$in:picked_tags.array()
                ).count()
            # console.log 'count', count
            count is 2
            
            
            
    Template.flat_tag_avatar.onCreated ->
        @autorun => @subscribe 'flat_ref_doc', @data, ->
            
    Template.flat_tag_avatar.events
        'click .flat_tag_pick': ->
            # console.log @
            picked_tags.clear()
            picked_tags.push @valueOf()
            Session.set('viewing_post_id',null)
    Template.flat_tag_avatar.helpers
        ref_doc_flat: ->
            # console.log @valueOf()
            found = Docs.findOne 
                model:'post'
                title:@valueOf()
            if found 
                found
            else 
                Docs.findOne
                    model:'post'
                    tags:$in:[@valueOf()]
    
    Template.tag_picker.helpers
        ref_doc: ->
            # console.log @valueOf()
            found = 
                Docs.findOne 
                    model:'post'
                    title:@title
            if found 
                found
            else 
                Docs.findOne
                    model:'post'
                    tags:$in:[@title]
    
    Template.home.helpers        
        picked_tags: -> picked_tags.array()
    
        # post_docs: ->
        #     Docs.find 
        #         model:'post'
        tag_results: ->
            doc_count = Docs.find({
                model:'post'
                tags:$all:picked_tags.array()
                }).count()
            # console.log 'count', doc_count
            if doc_count > 0
                Results.find {
                    count:$lt:doc_count
                    model:'post_tag'
                }, sort:_timestamp:-1
            else
                Results.find {
                    model:'post_tag'
                }, sort:_timestamp:-1
    
        ref_doc_flat: ->
            found = 
                Docs.findOne 
                    model:'post'
                    title:@valueOf()
            if found 
                found
            else 
                Docs.findOne
                    model:'post'
                    tags:$in:[@valueOf()]
    
        current_post: ->
            Docs.findOne
                _id:Session.get('viewing_post_id')
                
        home_items: ->
            match = {
                model:'post'
            }
            # if picked_tags?.array().length > 0
            match.tags = $in:picked_tags.array()
            Docs.find match,
                sort:views:-1
           
    Template.unpick_tag.helpers
        ref_doc_flat: ->
            # console.log @
            
            match = {}
            match.app = 'bc'
            match.model = 'post'
            match.title = @valueOf()
            found = 
                Docs.findOne match
            if found
                found 
            else 
                # console.log found
                match.title = null
                match.tags = $in: [@valueOf()]
                Docs.findOne match
                
    
           
                
    Template.home_item.helpers
        card_class: ->
            if Session.equals('viewing_post_id', @_id) then 'inverted large' else 'small basic' 
        is_selected: -> Session.equals('viewing_post_id', @_id)
    Template.home_item.events
        'click .edit_this': ->
            Session.set('is_editing',@_id)
        'click .save_this': ->
            Session.set('is_editing',false)
    Template.home_item.helpers
        is_editing: -> Session.equals('is_editing',@_id)
    # Template.home_item.helpers
    #     is_editing: -> Session.get('is_editing')
    Template.home_item.events
        'click .view_item': ->
            Session.set('viewing_post_id', @_id)
            Docs.update @_id, 
                $inc:views:1
    Template.home.events
        'click .read': (e,t)-> 
            if @tone 
                window.speechSynthesis.cancel()
                for sentence in @tone.result.sentences_tone
                    console.log sentence
                    Session.set('current_reading_sentence',sentence)
                    window.speechSynthesis.speak new SpeechSynthesisUtterance sentence.text
    
        'click .add_post': ->
            new_id = Docs.insert 
                model:'post'
                tags:picked_tags.array()
                title:picked_tags.array().toString()
            Session.set('viewing_post_id', new_id)    
            Session.set('is_editing', @_id)    
        'click .unpick_tag': -> 
            Session.set('viewing_post_id', null)
            picked_tags.remove @valueOf()
        'keyup .search_title': (e,t)->
            search = $('.search_title').val().toLowerCase().trim()
            # _.throttle( =>
    
            # if search.length > 4
            #     Session.set('query',search)
            # else if search.length is 0
            #     Session.set('query','')
            if e.which is 13
                window.speechSynthesis.cancel()
                # console.log search
                if search.length > 0
                    # Meteor.call 'check_url', search, (err,res)->
                    #     console.log res
                    #     if res
                    #         alert 'url'
                    #         Meteor.call 'lookup_url', search, (err,res)=>
                    #             console.log res
                    #             for tag in res.tags
                    #                 picked_tags.push tag
                    #             Session.set('skip',0)
                    #             Session.set('query','')
                    #             $('.search_title').val('')
                    #     else
                    # unless search in picked_tags.array()
                    picked_tags.push search
                    # console.log 'selected tags', picked_tags.array()
                    # Meteor.call 'call_alpha', search, ->
                    Meteor.call 'search_ddg', search, ->
                    # if Session.equals('view_mode','porn')
                    #     Meteor.call 'search_ph', search, ->
                    # else
                    # window.speechSynthesis.speak new SpeechSynthesisUtterance search
                    window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
                    Meteor.call 'call_alpha', picked_tags.array().toString(), ->
                    Meteor.call 'call_wiki', search, ->
                    Meteor.call 'search_reddit', picked_tags.array(), ->
                    Session.set('viewing_doc',null)
    
                    Session.set('skip',0)
                    # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
    
                    # Session.set('query','')
                    $('.search_title').val('')
                    Meteor.setTimeout( ->
                        Session.set('toggle',!Session.get('toggle'))
                    , 10000)
            # if e.which is 8
            #     if search.length is 0
            #         picked_tags.pop()
        # , 1000)



if Meteor.isServer 
    Meteor.publish 'checked_in_users', ->
        Meteor.users.find
            checkedin:true
    Meteor.publish 'checkins', ->
        Docs.find 
            model:'checkin'
            
    Meteor.publish 'soup', ->
        Docs.find 
            model:'food'
            section:'soup'
            