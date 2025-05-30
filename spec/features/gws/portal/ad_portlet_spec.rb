require 'spec_helper'

describe "gws_portal_portlet", type: :feature, dbscope: :example, js: true do
  let(:site) { gws_site }
  let(:user) { gws_user }
  let(:ad_width) { rand(300..400) }
  let(:ad_speed) { rand(10..30) }
  let(:ad_pause) { rand(60..90) }
  let(:url) { "http://#{unique_id}.example.jp/" }

  before do
    login_gws_user
  end

  context "when ad portlet is created" do
    it do
      visit gws_portal_user_path(site: site, user: user)
      click_on I18n.t('gws/portal.links.manage_portlets')
      click_on I18n.t('ss.links.new')
      within '.main-box' do
        click_on I18n.t('gws/portal.portlets.ad.name')
      end
      within 'form#item-form' do
        within "#addon-gws-agents-addons-portal-portlet-ad" do
          fill_in "item[ad_width]", with: ad_width.to_s
          fill_in "item[ad_speed]", with: ad_speed.to_s
          fill_in "item[ad_pause]", with: ad_pause.to_s
        end

        within "#addon-gws-agents-addons-portal-portlet-ad_file" do
          within '[data-index="new"]' do
            upload_to_ss_file_field "item[ad_links][][file_id]", Rails.root.join("spec", "fixtures", "ss", "logo.png").to_s
          end
        end

        fill_in "item[ad_links][][url]", with: url

        click_on I18n.t('ss.buttons.save')
      end
      wait_for_notice I18n.t('ss.notice.saved')

      expect(Gws::Portal::UserPortlet.all.site(site).user(user).where(name: I18n.t('gws/portal.portlets.ad.name')).count).to eq 1
      portlet = Gws::Portal::UserPortlet.all.site(site).user(user).where(name: I18n.t('gws/portal.portlets.ad.name')).first
      expect(portlet.portlet_model).to eq "ad"
      expect(portlet.ad_width).to eq ad_width
      expect(portlet.ad_speed).to eq ad_speed
      expect(portlet.ad_pause).to eq ad_pause
      expect(portlet.ad_links.count).to eq 1
      portlet.ad_links.first.tap do |ad_link|
        expect(ad_link.name).to be_blank
        expect(ad_link.url).to eq url

        file = ad_link.file
        expect(file.name).to eq "logo.png"
        expect(file.filename).to eq "logo.png"
        expect(file.site_id).to be_blank
        expect(file.model).to eq Gws::Portal::UserPortlet.model_name.i18n_key.to_s
        expect(file.owner_item_id).to eq portlet.id
        expect(file.owner_item_type).to eq portlet.class.name
      end

      visit gws_portal_user_path(site: site, user: user)
      click_on I18n.t('gws/portal.links.arrange_portlets')
      # wait for ajax completion
      expect(page).to have_css(".portlet-model-ad[data-id='#{portlet.id}']", text: portlet.name)
      click_on I18n.t('gws/portal.buttons.save_layouts')
      wait_for_notice I18n.t('ss.notice.saved')
      portlet.reload
      portlet.ad_links.first.tap do |ad_link|
        expect(ad_link.url).to eq url

        file = ad_link.file
        expect(file.name).to eq "logo.png"
        expect(file.filename).to eq "logo.png"
        expect(file.site_id).to be_blank
        expect(file.model).to eq Gws::Portal::UserPortlet.model_name.i18n_key.to_s
        expect(file.owner_item_id).to eq portlet.id
        expect(file.owner_item_type).to eq portlet.class.name
      end

      visit gws_portal_user_path(site: site, user: user)
      expect(page).to have_css('.portlets .portlet-model-ad')
    end
  end

  context "when ad portlet is deleted" do
    let!(:setting) { create :gws_portal_user_setting, cur_user: user }
    let!(:portlet) { create :gws_portal_user_portlet, :gws_portal_ad_portlet, cur_user: user, setting: setting }

    it do
      expect(portlet.ad_links.count).to eq 1
      save_ad_link = portlet.ad_links.first
      save_file = save_ad_link.file
      expect(save_file.owner_item_id).to eq portlet.id

      visit gws_portal_user_path(site: site, user: user)
      click_on I18n.t('gws/portal.links.manage_portlets')
      click_on portlet.name
      within ".nav-menu" do
        click_on I18n.t("ss.links.delete")
      end
      within 'form#item-form' do
        click_on I18n.t("ss.buttons.delete")
      end
      wait_for_notice I18n.t('ss.notice.deleted')

      expect { portlet.reload }.to raise_error Mongoid::Errors::DocumentNotFound
      expect { save_file.reload }.to raise_error Mongoid::Errors::DocumentNotFound
    end
  end

  context "when only ad image on ad portlet is deleted" do
    let!(:setting) { create :gws_portal_user_setting, cur_user: user }
    let!(:portlet) { create :gws_portal_user_portlet, :gws_portal_ad_portlet, cur_user: user, setting: setting }

    it do
      expect(portlet.ad_links.count).to eq 1
      save_ad_link = portlet.ad_links.first
      save_file = save_ad_link.file
      expect(save_file.owner_item_id).to eq portlet.id

      visit gws_portal_user_path(site: site, user: user)
      click_on I18n.t('gws/portal.links.manage_portlets')
      click_on portlet.name
      click_on I18n.t("ss.links.edit")
      within 'form#item-form' do
        within "#addon-gws-agents-addons-portal-portlet-ad_file" do
          within first("[data-index] .ss-file-field-v2") do
            click_on "delete"
          end
        end

        click_on I18n.t('ss.buttons.save')
      end
      wait_for_notice I18n.t('ss.notice.saved')

      portlet.reload
      expect(portlet.ad_links.count).to eq 1
      ad_link = portlet.ad_links.first
      expect(ad_link.id).to eq save_ad_link.id
      expect(ad_link.file).to be_blank

      expect { save_file.reload }.to raise_error Mongoid::Errors::DocumentNotFound
    end
  end

  context "when only row is deleted" do
    let!(:setting) { create :gws_portal_user_setting, cur_user: user }
    let!(:portlet) { create :gws_portal_user_portlet, :gws_portal_ad_portlet, cur_user: user, setting: setting }

    it do
      expect(portlet.ad_links.count).to eq 1
      save_ad_link = portlet.ad_links.first
      save_file = save_ad_link.file
      expect(save_file.owner_item_id).to eq portlet.id

      visit gws_portal_user_path(site: site, user: user)
      click_on I18n.t('gws/portal.links.manage_portlets')
      click_on portlet.name
      click_on I18n.t("ss.links.edit")
      within 'form#item-form' do
        within "#addon-gws-agents-addons-portal-portlet-ad_file" do
          within first("[data-index]") do
            click_on "remove"
          end
        end

        click_on I18n.t('ss.buttons.save')
      end
      wait_for_notice I18n.t('ss.notice.saved')

      portlet.reload
      expect(portlet.ad_links.count).to eq 1
      ad_link = portlet.ad_links.first
      expect(ad_link.id).not_to eq save_ad_link.id

      expect { save_file.reload }.to raise_error Mongoid::Errors::DocumentNotFound
    end
  end

  context "when ss/user_file is attached" do
    let(:content) { Rails.root.join("spec", "fixtures", "ss", "logo.png").to_s }
    let!(:file) do
      tmp_ss_file(SS::UserFile, model: SS::UserFile::FILE_MODEL, user: user, contents: content)
    end

    before do
      @save_file_upload_dialog = SS.file_upload_dialog
      SS.file_upload_dialog = :v2

      ActionMailer::Base.deliveries.clear
    end

    after do
      SS.file_upload_dialog = @save_file_upload_dialog

      ActionMailer::Base.deliveries.clear
    end

    it do
      visit gws_portal_user_path(site: site, user: user)
      click_on I18n.t('gws/portal.links.manage_portlets')
      click_on I18n.t('ss.links.new')
      within '.main-box' do
        click_on I18n.t('gws/portal.portlets.ad.name')
      end
      within 'form#item-form' do
        within "#addon-gws-agents-addons-portal-portlet-ad" do
          fill_in "item[ad_width]", with: ad_width.to_s
          fill_in "item[ad_speed]", with: ad_speed.to_s
          fill_in "item[ad_pause]", with: ad_pause.to_s
        end

        within "#addon-gws-agents-addons-portal-portlet-ad_file" do
          within '[data-index="new"]' do
            wait_for_cbox_opened { click_on I18n.t("ss.buttons.upload") }
          end
        end
      end
      wait_for_event_fired "turbo:frame-load" do
        within_dialog do
          within ".cms-tabs" do
            click_on I18n.t("ss.buttons.select_from_list")
          end
        end
      end
      within_dialog do
        wait_for_event_fired "turbo:frame-load" do
          within "form.search" do
            check I18n.t("sns.user_file")
          end
        end
      end
      within_dialog do
        expect(page).to have_css('.file-view', text: file.name)
        wait_for_cbox_closed { click_on file.name }
      end
      within "form#item-form" do
        within '[data-index="new"]' do
          expect(page).to have_css(".humanized-name", text: file.humanized_name)
          fill_in "item[ad_links][][url]", with: url
        end

        click_on I18n.t('ss.buttons.save')
      end
      wait_for_notice I18n.t('ss.notice.saved')

      expect(Gws::Portal::UserPortlet.all.site(site).user(user).where(name: I18n.t('gws/portal.portlets.ad.name')).count).to eq 1
      portlet = Gws::Portal::UserPortlet.all.site(site).user(user).where(name: I18n.t('gws/portal.portlets.ad.name')).first
      expect(portlet.portlet_model).to eq "ad"
      expect(portlet.ad_width).to eq ad_width
      expect(portlet.ad_speed).to eq ad_speed
      expect(portlet.ad_pause).to eq ad_pause
      expect(portlet.ad_links.count).to eq 1
      portlet.ad_links.first.tap do |ad_link|
        expect(ad_link.name).to be_blank
        expect(ad_link.url).to eq url

        attached_file = ad_link.file
        expect(attached_file.id).not_to eq file.id
        expect(attached_file.name).to eq file.name
        expect(attached_file.filename).to eq file.filename
        expect(attached_file.site_id).to be_blank
        expect(attached_file.model).to eq Gws::Portal::UserPortlet.model_name.i18n_key.to_s
        expect(attached_file.owner_item_id).to eq portlet.id
        expect(attached_file.owner_item_type).to eq portlet.class.name
      end
      SS::File.find(file.id).tap do |after_attached|
        expect(after_attached.model).to eq file.model
        expect(after_attached.owner_item_id).to be_blank
        expect(after_attached.owner_item_type).to be_blank
      end

      visit gws_portal_user_path(site: site, user: user)
      click_on I18n.t('gws/portal.links.arrange_portlets')
      # wait for ajax completion
      expect(page).to have_css(".portlet-model-ad[data-id='#{portlet.id}']", text: portlet.name)
      click_on I18n.t('gws/portal.buttons.save_layouts')
      wait_for_notice I18n.t('ss.notice.saved')
      portlet.reload
      portlet.ad_links.first.tap do |ad_link|
        expect(ad_link.url).to eq url

        attached_file = ad_link.file
        expect(attached_file.id).not_to eq file.id
        expect(attached_file.name).to eq file.name
        expect(attached_file.filename).to eq file.filename
        expect(attached_file.site_id).to be_blank
        expect(attached_file.model).to eq Gws::Portal::UserPortlet.model_name.i18n_key.to_s
        expect(attached_file.owner_item_id).to eq portlet.id
        expect(attached_file.owner_item_type).to eq portlet.class.name
      end

      visit gws_portal_user_path(site: site, user: user)
      expect(page).to have_css('.portlets .portlet-model-ad')
    end
  end
end
