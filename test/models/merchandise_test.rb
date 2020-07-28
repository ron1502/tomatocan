require 'test_helper'

class MerchandiseTest < ActiveSupport::TestCase

  def setup
    @merchandise = merchandises(:one)
    @all_merchandises = merchandises
    @merchandise_attachments = [:merchpdf,:merchmobi,:graphic,:video,:merchepub,:audio]

    @carrierwave_cache_path = "#{Rails.root}/test/support/carrierwave/carrierwave_cache/"
    @default_cache_path = "#{Rails.root}\/tmp\/uploads/"
    @png = File.open("test/fixtures/files/uploader_test/pictureTest.png")
    @mp3 = File.open("test/fixtures/files/uploader_test/soundTest.mp3")
    @mp4 = File.open("test/fixtures/files/uploader_test/videoTest.mp4")
    @pdf = File.open("test/fixtures/files/uploader_test/pdfTest.pdf")
    @mobi = File.open("test/fixtures/files/uploader_test/mobiTest.mobi")
    @epub = File.open("test/fixtures/files/uploader_test/epubTest.epub")
  end

  #Uploaders
  test "MerchpicUploader" do
    testUploader(@merchandise, @merchandise.itempic, @png,
       /#{@default_cache_path}[\d-]*\/pictureTest\.png/)
  end

  test "AudioUploader" do
    testUploader(@merchandise, @merchandise.audio, @mp3,
       /#{@default_cache_path}[\d-]*\/soundTest\.mp3/)
  end

  test "VideoUploader" do
    testUploader(@merchandise, @merchandise.video, @mp4,
       /#{@default_cache_path}[\d-]*\/videoTest\.mp4/)
  end

  test "GraphicUploader" do
    testUploader(@merchandise, @merchandise.graphic, @png,
       /#{@default_cache_path}[\d-]*\/pictureTest\.png/)
  end

  test "MerchepubUploader" do
    testUploader(@merchandise, @merchandise.merchepub, @epub,
       /#{@carrierwave_cache_path}[\d-]*\/epubTest\.epub/)
  end

  test "MerchemobiUploader" do
    testUploader(@merchandise, @merchandise.merchmobi, @mobi,
       /#{@carrierwave_cache_path}[\d-]*\/mobiTest\.mobi/)
  end

  test "MerchpdfUploader" do
    testUploader(@merchandise, @merchandise.merchpdf, @pdf,
       /#{@default_cache_path}[\d-]*\/pdfTest\.pdf/)
  end

  test "validate price" do
    # test merchandise with empty price
    merchandise = Merchandise.new(name: "testproduct", user_id:1, price:nil, buttontype:"Buy")
    refute merchandise.valid?
    refute_empty merchandise.errors[:price]

    # test merchandise with an invalid price
    merchandise.price = "1.5+3.14s"
    refute merchandise.valid?
    assert merchandise.errors[:price].any?

    # test merchandise with valid price (only contain numbers)
    merchandise.price = merchandises(:one).price
    assert merchandise.valid?
  end

 test "validate presence of name" do
    # test merchandise with empty name
    merchandise = Merchandise.new(name: nil, user_id:1, price:1.5, buttontype:"Donate")
    refute merchandise.valid?
    refute_empty merchandise.errors[:name]

    # test merchandise with valid name
    merchandise.name = merchandises(:one).name
    assert merchandise.valid?
  end

 test "validate presence of buttontype" do
    # test merchandise with empty buttontype
    merchandise = Merchandise.new(name: "testproduct", user_id:1, price:1.5, buttontype:nil)
    refute merchandise.valid?
    refute_empty merchandise.errors[:buttontype]

    # test merchandise with valid buttontype
    merchandise.buttontype = "Donate"
    assert merchandise.valid?
  end

  test "buttontype should only be Buy or Donate" do
    @merchandise.buttontype = "string"
    refute @merchandise.valid?, 'saved an invalid value for buttontype'
  end

  test "price should be numerical" do
    @merchandise.price = "string"
    refute @merchandise.valid?, 'saved merchandise with a non numerical price'
  end

  test "parse youtube for merchandise" do
    youtubeT = "http://youtube.com/watch?v=/frlviTJc"
    regex = /(?:youtu.be\/|youtube.com\/watch\?v=|\/(?=p\/))([\w\/\-]+)/
    @merchandise.youtube = youtubeT
    @merchandise.get_youtube_id
    refute_equal(youtubeT, @merchandise.youtube)
    assert_equal youtubeT.match(regex)[1], @merchandise.youtube, "Youtube field contains unknown id"
  end

  test 'get_filename_and_data validation' do
    filename_and_data_all = @all_merchandises.each { |x| x.get_filename_and_data }
    @merchandise_attachments.each do |x|
      assert_equal @all_merchandises.each { |p| p[x] }, filename_and_data_all.each { |q| q[x] }
    end
  end

end
