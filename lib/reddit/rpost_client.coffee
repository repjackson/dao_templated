if Meteor.isClient
    Template.registerHelper 'embed', ()->
        if @rd and @rd.media and @rd.media.oembed and @rd.media.oembed.html
            dom = document.createElement('textarea')
            # dom.innerHTML = doc.body
            dom.innerHTML = @rd.media.oembed.html
            # console.log 'innner html', dom.value
            return dom.value
            # Docs.update @_id,
            #     $set:
            #         parsed_selftext_html:dom.value
    
    
    Template.registerHelper 'youtube_parse', ()->
        # console.log @url
        regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
        match = @url.match(regExp);
        if match and match[2].length is 11
            return match[2];
        else
            console.log 'no'
    
    
    Template.registerHelper 'is_image', ()->
        @domain in ['i.imgur.com','i.reddit.com','i.redd.it','imgur.com']
    
    Template.registerHelper 'is_youtube', ()->
        @domain in ['youtube.com','youtu.be','m.youtube.com','vimeo.com']
    Template.registerHelper 'is_twitter', ()->
        @domain in ['twitter.com','mobile.twitter.com','vimeo.com']
    
    
