# encoding: utf-8

require 'uri'
require 'net/http'
require 'singleton'
require 'observer'

=begin rdoc
= Classe Urls

 - Gère une url et son nuage associé
=end
class Url

  attr_reader :name, :time, :nuage

  def initialize(url)
    @name = url
    @time = Time.now
    @nuage = Nuage.new(get_content)
    @lastmodified = nil
  end

  def nuage=(content)
    @nuage = Nuage.new(content)
  end

  def get_content
    begin
     proto,user,host,port,reg,path,opaq,query,fragment = URI.split(@name)
     if proto == 'http' then
       # GET page à traiter
       port = port || 80
       path = '/' if path == ''
       http = Net::HTTP.new(host, port)
       reponse = http.get(path)
       #reponse.header.each_header {|key,value| puts "#{key} = #{value}" }
       @lastmodified = reponse.header['last-modified'] if reponse.header['last-modified']
       encoding = nil
       encoding = $1 if reponse.header['content-type'] =~ /charset=(.*)/i
       encoding = $1 if not encoding and reponse.body =~ /<meta [^<]+charset=([^"']+)/i
 encoding = 'ISO-8859-1' if not encoding
       reponse.body.force_encoding(encoding) if encoding
       reponse.body.encode('utf-8')
     end
    rescue
     p $!
     nil
    end
  end

end

=begin rdoc
= Classe Nuage

 - Produit un nuage des mots les plus fréquents
=end
class Nuage
  @@font_max = 5

  NOISE_WORDS = {
      :fr => ['a', "ai", "au", "ait", "c", "ca", "car", "ce", "ces", "cela", "celle", "cette", "ces", "d", "dans", "de", "du", "des", "dont", "en", "elle", "es", "est", "et", "il", "ils", "j", "je", "l", "le", "la", "les", "m", "ma", "me", "mes", "mon", "n", "ne", "ni", "ou", "pas", "plus", "pour", "qu", "que", "qui", "quel", "quelles", "s", "sa", "se", "ses", "son", "t", "ta", "te", "tes", "ton", "un", "une", "va", "y", "assert","class","def","end","equal","new","x"],
      :en => ['a','an','are','and','be','border','s','lt','font','for','gt','is','in','left','margin','ma','mes','mon','n','nbsp','of','our','padding','par','pour','r','top','to','the','this','we','which','while','8217','5em','0','1','2']
      }

  def initialize(content, lang=:fr, nbmots=20, font_max=5)
    @content = content
    @nbmots = nbmots
    @font_max = font_max
    @lang = lang
    @total_mots = 0
    @mots_frequences = frequences
  end

  attr_reader :mots_frequences, :total_mots

  def frequences
    mot_freq = Hash.new(0)
    if @content then
      @content.gsub!(/.*<body/m,' ')
      @content.gsub!(/<\/?[^>]*>/,' ')
      @content.gsub!(/&[^;]+;/,' ')
      @content.tr!("àçéèêîôù","aceeeiou")
      words = @content.downcase.scan(/[a-z0-9]+/)
      @total_mots = words.length
      words.each {|word| mot_freq[word] += 1 unless NOISE_WORDS[@lang].index(word) }
    end
    mot_freq
  end

  def normalize
    if @nbmots <= @mots_frequences.size
     mft = @mots_frequences.sort{|a,b| a[1] <=> b[1]}[-(@nbmots), @nbmots]
    else
     mft = @mots_frequences.sort{|a,b| a[1] <=> b[1]}
    end
    p "#{@nbmots} ****** #{@mots_frequences.size}"
    max = @mots_frequences.sort{|a,b| a[1] <=> b[1]}[-1][1]
    max = mft.sort{|a,b| a[1] <=> b[1]}[-1][1]
    mft.sort{|a,b| a[0] <=> b[0]}.collect { |k,v|
      [k, v, ((v * (@font_max - 1))/max.to_f).floor + 1]
    }
  end

  def do_div
    div = "<div class='nuage'>\n"
    (normalize.sort{|a,b| a[0] <=> b[0]}).each { |m,f,t|
      div <<= "<span class='n#{t}'><a href='#' title='#{f}'>#{m}<sub>#{f}</sub></a></span>\n"
    }
    div <<= "</div>\n"
  end

  def self.do_style
      style = "<style type='text/css'>\n"
      (1..@@font_max).each do |i|
         style <<= ".n#{i}{font-size:#{(i*0.2)+1}em;position:relative;z-index:#{@@font_max - i}}\n"
      end
      style <<= ".nuage {line-height:2.4em;max-width:50%;text-align:justify;margin:1em 1em 0 1em;}\n"
      style <<= ".nuage a:link{text-decoration:none;}\n"
      style <<= ".nuage a:hover{background-color:silver;}\n"
      style <<= ".nuage a:visited{text-decoration:none;}\n"
      style <<= "sub {color:black;}"
      style <<= "</style>\n"
  end

end #class


# calcule des nuages si le programme courant est ce fichier
if $0 == __FILE__ then
    ['http://www.ingesup.com/ecole-informatique/toulouse.html','http://www.bibliotheque.toulouse.fr/accueil_mediatheque.html','http://csrp.iut-blagnac.fr/~jmi/rubym2igs/','http://coin.des.experts.pagesperso-orange.fr/reponses/faq9_56.html','http://ruby-doc.org/docs/beginner-fr/xhtml/'].each { |url|
     u = Url.new(url)
     p u.nuage.mots_frequences
     p u.nuage.do_div
    }
end