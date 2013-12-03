=begin rdoc
= Tests du serveur APPLI

 usage: ruby cycle6Test.rb
=end

require './cycle6'
require 'net/http'
require 'test/unit'

STDOUT.sync = true

=begin rdoc
= Classe de test du serveur APPLI
=end
class APPLITest < Test::Unit::TestCase
  def setup
    @appli = APPLI.new()
    @thread = Thread.start{ @appli.start }
  end
  def teardown
      @appli.stop
  end
  def test_302_GET
      http = Net::HTTP.new("127.0.0.1", 5555)
      requete = Net::HTTP::Get.new("/")
      http.request(requete){|reponse| assert_equal("302", reponse.code)}
      requete = Net::HTTP::Get.new("/mobile")
      http.request(requete){|reponse| assert_equal("302", reponse.code)}
  end
  def test_302_POST
      http = Net::HTTP.new("127.0.0.1", 5555)
      params = "url=http://1.2.3/fr"
      reponse,body = http.post("/urls", params)
      assert_equal("302",reponse.code)
      params = "url=http://4.5.6/fr"
      reponse,body = http.post("/mobile/urls", params)
      assert_equal("302",reponse.code)
  end
  def test_200
      http = Net::HTTP.new("127.0.0.1", 5555)
      requete = Net::HTTP::Get.new("/urls")
      http.request(requete){|reponse| assert_equal("200", reponse.code)}
      requete = Net::HTTP::Get.new("/mobile/urls")
      http.request(requete){|reponse| assert_equal("200", reponse.code)}
  end
  def test_Title
      http = Net::HTTP.new("127.0.0.1", 5555)
      requete = Net::HTTP::Get.new("/urls")
      http.request(requete){|reponse| assert_match(/<title>Serveur APPLI - v.*<\/title>/,reponse.body)}
      requete = Net::HTTP::Get.new("/mobile/urls")
      http.request(requete){|reponse| assert_match(/<title>Serveur APPLI - v.*<\/title>/,reponse.body)}
  end
  def test_Page_urls
      http = Net::HTTP.new("127.0.0.1", 5555)
      re0 = %r|<html><head>.*</head><body>.*<ol>.*</ol>.*</body></html>
|m
      re1 = %r|<html><head>
<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
<title>Serveur APPLI - v#{APPLI::VERSION}</title>
<style[^>]*>.*</style>

</head><body>.*</body></html>
|m
      re2 = %r|<html><head>.*</head><body><hr/>
<center><h2>Hello web</h2></center>
<form method="POST">
<input type="text" name="url" size="80" value="Nouvelle url" />
<input type="submit" value="Enregistrer">
</form>
<hr/>
<ol>.*</ol>
<hr/>
<div style="text-align:right;">Serveur APPLI - v#{APPLI::VERSION}</div>
<hr/></body></html>
|m
      requete = Net::HTTP::Get.new("/urls")
      http.request(requete){|reponse| assert_match(re0,reponse.body,'Erreur page')}
      http.request(requete){|reponse| assert_match(re1,reponse.body,'Erreur head')}
      http.request(requete){|reponse| assert_match(re2,reponse.body,'Erreur body')}
  end
  def test_Page_mobile_urls
      http = Net::HTTP.new("127.0.0.1", 5555)
      re0 = %r|<html><head>.*</head><body>.*</body></html>
|m
      re1 = %r|<html><head>
<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
<title>Serveur APPLI - v#{APPLI::VERSION}</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="http://code.jquery.com/mobile/1.1.0-rc.1/jquery.mobile-1.1.0-rc.1.min.css" />
<script src="http://code.jquery.com/jquery-1.7.1.min.js"></script>
<script src="http://code.jquery.com/mobile/1.1.0-rc.1/jquery.mobile-1.1.0-rc.1.min.js"></script>
\s*<style[^>]*>.*</style>

</head><body>.*</body></html>
|m
      re2 = %r|<html><head>.*</head><body>
<div data-role="page">
<div data-role="header">
<h1>Hello web</h1>
</div>
<div data-role="content">
<form method="POST">
<input type="text" name="url" size="80" value="Nouvelle url" />
<input type="submit" value="Enregistrer">
</form>
<ol data-role="listview" data-inset="true">.*</ol>
</div>
</div>.*
<div data-role="footer">
<h4>Hello web</h4>
</div><!-- /footer -->
</div><!-- /page -->
</body></html>
|m
      requete = Net::HTTP::Get.new("/mobile/urls")
      http.request(requete){|reponse| assert_match(re0,reponse.body,'Erreur page')}
      http.request(requete){|reponse| assert_match(re1,reponse.body,'Erreur head')}
      http.request(requete){|reponse| assert_match(re2,reponse.body,'Erreur body')}
  end
  def test_urls
      http = Net::HTTP.new("127.0.0.1", 5555)
      requete = Net::HTTP::Get.new("/urls")
      urls = ['http://www.ingesup.com/ecole-informatique/toulouse.html','http://www.bibliotheque.toulouse.fr/accueil_mediatheque.html','http://csrp.iut-blagnac.fr/~jmi/rubym2igs/'
      ]
      http.request(requete){|reponse|
       urls.each {|url|
        re = %r|<li><a href="#{url}">#{url}</a> - \d+ \D+ \d+ - \d+:\d+:\d+
<form method="POST">
<input type="hidden" name="url" value="#{url}" />
<input type="submit" name="delete" value="Supprimer">
</form>|
        assert_match(re,reponse.body)
       }
      }
  end
  def test_mobile_urls
      http = Net::HTTP.new("127.0.0.1", 5555)
      requete = Net::HTTP::Get.new("/mobile/urls")
      urls = ['http://www.ingesup.com/ecole-informatique/toulouse.html','http://www.bibliotheque.toulouse.fr/accueil_mediatheque.html','http://csrp.iut-blagnac.fr/~jmi/rubym2igs/'
      ]
      http.request(requete){|reponse|
       urls.each {|url|
        re = %r|<li><a href="#{url}">#{url}</a>
<form method="POST">
<input type="hidden" name="url" value="#{url}" />
<input type="submit" name="delete" value="Supprimer" data-inline="true">
<span>\d+ \D+ \d+  - \d+:\d+:\d+</span>
</form>
<a href="\#u\d+" ></a>
</li>|
        assert_match(re,reponse.body)
       }
      }
  end
  def test_Form
      http = Net::HTTP.new("127.0.0.1", 5555)
      re = %r|<form method="POST">
<input type="text" name="url" size="80" value="Nouvelle url" />
<input type="submit" value="Enregistrer">
</form>|
      requete = Net::HTTP::Get.new("/urls")
      http.request(requete){|reponse| assert_match(re,reponse.body)}
      requete = Net::HTTP::Get.new("/mobile/urls")
      http.request(requete){|reponse| assert_match(re,reponse.body)}
  end
  def test_POST
      # saisie d'une url
      http = Net::HTTP.new("127.0.0.1", 5555)
      params = "url=http://www.ruby-lang.org/fr"
      reponse,body = http.post("/urls", params)
      assert_equal("302",reponse.code)
      # l'url est alors dans la liste
      requete = Net::HTTP::Get.new("/urls")
      http.request(requete){|reponse|
        re = %r|<li><a href="http://www.ruby-lang.org/fr">http://www.ruby-lang.org/fr</a> - \d+ \D+ \d+ - \d+:\d+:\d+
<form method="POST">
<input type="hidden" name="url" value="http://www.ruby-lang.org/fr" />
<input type="submit" name="delete" value="Supprimer">
</form>|

        assert_match(re,reponse.body)
      }
  end
  def test_POST_mobile
      # saisie d'une url
      http = Net::HTTP.new("127.0.0.1", 5555)
      params = "url=http://www.ruby-lang.org/en/"
      reponse,body = http.post("/mobile/urls", params)
      assert_equal("302",reponse.code)
      # l'url est alors dans la liste
      requete = Net::HTTP::Get.new("/mobile/urls")
      http.request(requete){|reponse|
        re = %r|<li><a href="http://www.ruby-lang.org/en/">http://www.ruby-lang.org/en/</a>
<form method="POST">
<input type="hidden" name="url" value="http://www.ruby-lang.org/en/" />
<input type="submit" name="delete" value="Supprimer" data-inline="true">
<span>\d+ \D+ \d+  - \d+:\d+:\d+</span>
</form>
<a href="\#u\d+" ></a>
</li>|

        assert_match(re,reponse.body)
      }
  end
  def test_POST_Delete
      # suppression d'une url
      http = Net::HTTP.new("127.0.0.1", 5555)
      params = "url=http://csrp.iut-blagnac.fr/~jmi/rubym2igs/&delete=Supprimer"
      reponse,body = http.post("/urls", params)
      assert_equal("302",reponse.code)
      # les urls restantes
      urls = ['http://www.ingesup.com/ecole-informatique/toulouse.html',
      'http://www.bibliotheque.toulouse.fr/accueil_mediatheque.html',
      'http://coin.des.experts.pagesperso-orange.fr/reponses/faq9_56.html',
      'http://ruby-doc.org/docs/beginner-fr/xhtml/'
      ]
      requete = Net::HTTP::Get.new("/urls")
      http.request(requete){|reponse|
       urls.each {|url|
        re = %r|<li><a href="#{url}">#{url}</a> - \d+ \D+ \d+ - \d+:\d+:\d+
<form method="POST">
<input type="hidden" name="url" value="#{url}" />
<input type="submit" name="delete" value="Supprimer">
</form>|
        assert_match(re,reponse.body)
        assert( not( %r|http://csrp.iut-blagnac.fr/~jmi/rubym2igs/| =~ reponse.body) )
       }
      }
  end
  def test_POST_Delete_mobile
      # suppression d'une url
      http = Net::HTTP.new("127.0.0.1", 5555)
      params = "url=http://csrp.iut-blagnac.fr/~jmi/rubym2igs/&delete=Supprimer"
      reponse,body = http.post("/mobile/urls", params)
      assert_equal("302",reponse.code)
      # les urls restantes
      urls = ['http://www.ingesup.com/ecole-informatique/toulouse.html',
      'http://www.bibliotheque.toulouse.fr/accueil_mediatheque.html',
      'http://coin.des.experts.pagesperso-orange.fr/reponses/faq9_56.html',
      'http://ruby-doc.org/docs/beginner-fr/xhtml/'
      ]
      requete = Net::HTTP::Get.new("/mobile/urls")
      http.request(requete){|reponse|
       urls.each {|url|
        re = %r|<li><a href="#{url}">#{url}</a>
<form method="POST">
<input type="hidden" name="url" value="#{url}" />
<input type="submit" name="delete" value="Supprimer" data-inline="true">
<span>\d+ \D+ \d+  - \d+:\d+:\d+</span>
</form>
<a href="\#u\d+" ></a>
</li>|
        assert_match(re,reponse.body)
        assert( not( %r|http://csrp.iut-blagnac.fr/~jmi/rubym2igs/| =~ reponse.body) )
       }
      }
  end
end