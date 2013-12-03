# encoding: utf-8

require './nuage'
require 'test/unit'

=begin rdoc
= Classe de test de la classe Nuage
=end
class NuageTest < Test::Unit::TestCase

=begin rdoc
 Tire au hazard une fréquence d'apparition pour chaque mot
 retourne [nb_total_de_mots, {mot => freq , ...}]
=end
  def rand_freq(mots,max=20)
    h = {}
    total_mots = 0
    mots.each {|v| h[v] = rand(1..max) ; total_mots += h[v] }
    [total_mots, h]
  end
=begin rdoc
 Ajoute aléatoirement des balises,
 mélange balises et mots
 retourne une chaine contenant le tout
=end
  def freq2txt(h)
    nb, balises = rand_freq(['<html>','<br>','<hr />','<script x y=z t="t"></script>','</html>'])
    mots = h.merge(balises).collect {|k,v| [k] * v }.flatten!
    res = []
    mots.size.times do
        res << mots.delete_at(rand(mots.size))
    end
    res.join(' ')
  end

  def setup
  end
  def teardown
  end
  def test_fr
    mots = ['coucou','est','un','salut']
    total_mots, tirage = rand_freq(mots)
    nuage = Nuage.new(freq2txt(tirage))
    expected = tirage.delete_if {|k,v| Nuage::NOISE_WORDS[:fr].index(k) }

    assert_equal expected, nuage.frequences
    assert_equal 2, nuage.frequences.size
    assert_equal total_mots, nuage.total_mots

    assert_match %r|<div class='nuage'>.*</div>|m, nuage.do_div
    assert_match %r|<div class='nuage'>.*<span class='n\d'><a href='#' title='\d+'>coucou<sub>\d+</sub></a></span>.*<span class='n\d'><a href='#' title='\d+'>salut<sub>\d+</sub></a></span>.*</div>|m, nuage.do_div
  end

  def test_en
    mots = ['hi','is','an','hello','word']
    total_mots, tirage = rand_freq(mots)
    nuage = Nuage.new(freq2txt(tirage),:en)
    expected = tirage.delete_if {|k,v| Nuage::NOISE_WORDS[:en].index(k) }

    assert_equal expected, nuage.frequences
    assert_equal 3, nuage.frequences.size
    assert_equal total_mots, nuage.total_mots

    assert_match %r|<div class='nuage'>.*</div>|m, nuage.do_div
    assert_match %r|<div class='nuage'>.*<span class='n\d'><a href='#' title='\d+'>hello<sub>\d+</sub></a></span>.*<span class='n\d'><a href='#' title='\d+'>hi<sub>\d+</sub></a></span>.*<span class='n\d'><a href='#' title='\d+'>word<sub>\d+</sub></a></span>.*</div>|m, nuage.do_div
  end

  def test_styles
    assert_match %r|<style type='text/css'>.*</style>|m, Nuage.do_style
  end

end
