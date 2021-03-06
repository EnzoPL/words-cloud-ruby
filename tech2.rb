# encoding: utf-8

require 'net/http'
urls = [['www.ingesup.com',80,'/ecole-informatique/toulouse.html'],['www.bibliotheque.toulouse.fr',80,'/accueil_mediatheque.html'],['csrp.iut-blagnac.fr',80,'/~jmi/rubym2igs/'],['coin.des.experts.pagesperso-orange.fr',80,'/reponses/faq9_56.html'],['ruby-doc.org',80,'/docs/beginner-fr/xhtml/']]

urls.each {|host,port,path|
 http = Net::HTTP.new(host, port)
 reponse = http.get(path)
 encoding = nil
 encoding = $1 if reponse.header['content-type'] =~ /charset=(.*)/i
 encoding = $1 if not encoding and reponse.body =~ /<meta [^<]+charset=([^"']+)/i
 encoding = 'ISO-8859-1' if not encoding

 reponse.body.force_encoding(encoding.upcase) if encoding
 reponse.body.encode!('utf-8')
 
 reponse.body.gsub!(/.*<body/m,' ')
 reponse.body.gsub!(/<\/?[^>]*>/,' ')
 reponse.body.gsub!(/&[^;]+;/,' ')
 reponse.body.tr!("àçéèêîôù","aceeeiou")
 #p reponse.body
 words = reponse.body.downcase.scan(/[a-z]+/)
 p "#{host}#{path} : #{encoding} encoding, #{words.size} mots"
 #p words
}