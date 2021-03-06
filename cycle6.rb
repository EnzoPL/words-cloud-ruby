﻿# encoding: utf-8

=begin rdoc
= Cycle 6 : saisie des urls et nuage des mots

Serveur web APPLI

 usage: ruby cycle6.rb
Lance un serveur ruby webrick accessible
à l'url http://localhost:5555/
=end

require "webrick"
require "net/http"
require "./nuage"

=begin rdoc
= Serveur APPLI

 - Initialise et lance le serveur
 - Répond aux urls : /, /urls et /mobile/urls
=end
class APPLI
  VERSION = '1.0'

  def initialize(port=5555)
   @webrick = WEBrick::HTTPServer.new(
     :Port         => port,
     #:Logger       => WEBrick::Log.new($stderr, WEBrick::Log::DEBUG),
     :Logger       => WEBrick::Log.new($stderr, WEBrick::Log::ERROR),
     :AccessLog    => [
        [ $stderr, WEBrick::AccessLog::COMMON_LOG_FORMAT  ],
        [ $stderr, WEBrick::AccessLog::REFERER_LOG_FORMAT ],
        [ $stderr, WEBrick::AccessLog::AGENT_LOG_FORMAT   ],
      ]
    )
    @urls = {}
    # urls connues par défaut
   ['http://www.ingesup.com/ecole-informatique/toulouse.html',
   'http://www.bibliotheque.toulouse.fr/accueil_mediatheque.html',
   'http://csrp.iut-blagnac.fr/~jmi/rubym2igs/',
   'http://coin.des.experts.pagesperso-orange.fr/reponses/faq9_56.html',
   'http://ruby-doc.org/docs/beginner-fr/xhtml/'].each do |url|
           @urls[url] = Url.new(url)
    end

  end

 # Monte les urls  : / et /urls
 # Démarre le serveur (webrick)
  def start
      begin
      @webrick.mount("/", APPLIWI)
      @webrick.mount("/urls", APPLIWIURLS,@urls)
      @webrick.mount("/mobile/urls", APPLIWIURLS_M,@urls)
      @webrick.start
      end
  end

  def stop
    @webrick.shutdown
  end

end

# Interface HTTP du serveur APPLI pour /
class APPLIWI < WEBrick::HTTPServlet::AbstractServlet

=begin rdoc
- Redirige le navigateur vers /urls pour toute requête sur /
=end
  def do_GET(req, res)
    res.set_redirect(WEBrick::HTTPStatus::Found, "/mobile/urls") if req.path =~ /^\/mobile/
    res.set_redirect(WEBrick::HTTPStatus::Found, "/urls")
  end

  alias do_POST do_GET

end # class

# Interface HTTP du serveur APPLI pour /urls
class APPLIWIURLS < WEBrick::HTTPServlet::AbstractServlet
  MOIS=['oups','Janvier','Février','Mars','Avril','Mai','Juin','Juillet','Aout','Septembre','Octobre','Novembre','Décembre']

  def initialize(config,urls)
          super
          @urls = urls
          @nbmots = 10
  end

=begin rdoc
- Construit la page de réponse à une requête GET
- Retourne une liste des liens connus du serveur
=end
  def do_GET(req, res)
    res["content-type"] = "text/html"
    res.body = <<-EOF
<html><head>
<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
<title>Serveur APPLI - v#{APPLI::VERSION}</title>
#{Nuage.do_style}
</head><body><hr/>
<center><h2>Hello web</h2></center>
<form method="POST">
<input type="text" name="url" size="80" value="Nouvelle url" />
<input type="submit" value="Enregistrer">
</form>
<hr/>
<ol>
EOF

  @urls.each { |url,o|
   res.body <<= <<-EOF
<li><a href="#{o.name}">#{o.name}</a> - #{o.time.day} #{MOIS[o.time.mon]} #{o.time.year} #{o.time.strftime("- %T")}
<form method="POST">
<input type="hidden" name="url" value="#{o.name}" />
<input type="submit" name="delete" value="Supprimer">
</form>
     #{o.nuage.mots_frequences.size} mots différents sur #{o.nuage.total_mots} mots dans la page
     #{o.nuage.do_div}
</li>
EOF
   }
    res.body <<= <<-EOF
</ol>
<hr/>
<div style="text-align:right;">Serveur APPLI - v#{APPLI::VERSION}</div>
<hr/></body></html>
EOF
  end

=begin rdoc
- Supprime l'url fournie si delete est dans la requête
- Enregistre l'url fournie dans @urls
=end
  def do_POST(req, res)
    if req["content-length"].to_i > 1024*10
      raise WEBrick::HTTPStatus::Forbidden, "Taille des données trop grande"
    end

    if req.query['delete'] && req.query['url'] != ""
    then
            @urls.delete(req.query['url'])
    elsif req.query['url'] && req.query['url'] != ""
            @urls[req.query['url']] = Url.new(req.query['url'])
    end
    res.set_redirect(WEBrick::HTTPStatus::Found, "")
  end

end # class

class APPLIWIURLS_M < APPLIWIURLS
  def initialize(config,urls)
          super
          @urls = urls
  end

  def do_GET(req, res)
    res["content-type"] = "text/html"
    res.body = <<-EOF
<!DOCTYPE html>
<html><head>
<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
<title>Serveur APPLI - v#{APPLI::VERSION}</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="http://code.jquery.com/mobile/1.1.0-rc.1/jquery.mobile-1.1.0-rc.1.min.css" />
<script src="http://code.jquery.com/jquery-1.7.1.min.js"></script>
<script src="http://code.jquery.com/mobile/1.1.0-rc.1/jquery.mobile-1.1.0-rc.1.min.js"></script>
 #{Nuage.do_style}
</head><body>
<div data-role="page">
<div data-role="header">
<h1>Hello web</h1>
</div>
<div data-role="content">
<form method="POST">
<input type="text" name="url" size="80" value="Nouvelle url" />
<input type="submit" value="Enregistrer">
</form>
<ol data-role="listview" data-inset="true">
<li data-role="list-divider">urls</li>
EOF

  num = 0
  @urls.each { |url,o|
   res.body <<= <<-EOF
<li><a href="#{url}">#{url}</a>
<form method="POST">
<input type="hidden" name="url" value="#{url}" />
<input type="submit" name="delete" value="Supprimer" data-inline="true">
<span>#{o.time.day} #{MOIS[o.time.mon]} #{o.time.year} #{o.time.strftime(" - %T")}</span>
</form>
<a href="#u#{num += 1}" ></a>
</li>
EOF
   }
    res.body <<= <<-EOF
</ol>
</div>
</div><!-- /page -->
EOF

  num = 0
  @urls.each { |url,o|
   res.body <<= <<-EOF
<div data-role="page" id="u#{num += 1}"  data-add-back-btn="true">
<div data-role="header">
<h1>#{url}</h1>
</div><!-- /header -->

<div data-role="content">
<center>
#{o.time.day} #{MOIS[o.time.mon]} #{o.time.year} #{o.time.strftime(" - %T")}
</center>
 #{o.nuage.mots_frequences.size} mots différents sur #{o.nuage.total_mots} mots dans la page
<center>
 #{o.nuage.do_div}
</center>
</div><!-- /content -->

<div data-role="footer">
<h4>Hello web</h4>
</div><!-- /footer -->
</div><!-- /page -->
EOF
   }
    res.body <<= <<-EOF
</body></html>
EOF
  end
end # class APPLIWIURLS_M

# lance le serveur si le programme courant est ce fichier
if $0 == __FILE__ then
        port = ((ARGV.size > 0) and ARGV[0].to_i) || 5555
        appli = APPLI.new(port)
        trap(:INT){
         puts "Arret utilisateur"
         appli.stop
        }
        appli.start
end