require 'spec_helper'

describe "article_pages", type: :feature, dbscope: :example, js: true do
  let!(:site) { cms_site }
  let!(:admin) { cms_user }
  let!(:minimum_close_role) do
    create :cms_role, cur_site: site, name: "role-#{unique_id}", permissions: minimum_close_permissions
  end
  let!(:user1) { create :cms_test_user, group_ids: admin.group_ids, cms_role_ids: [ minimum_close_role.id ] }

  let!(:node) { create :article_node_page, cur_site: site, cur_user: admin, group_ids: admin.group_ids }
  let!(:page1) do
    create :article_page, cur_site: site, cur_user: admin, cur_node: node, group_ids: admin.group_ids, state: "public"
  end

  context "with minimum close permissions" do
    context "when page is closed in edit view" do
      let!(:minimum_close_permissions) do
        %w(read_private_cms_nodes read_private_article_pages edit_private_article_pages close_private_article_pages)
      end

      it do
        login_user user1
        visit article_pages_path(site: site, cid: node)
        expect(page).to have_css(".list-item[data-id='#{page1.id}']", text: page1.name)

        click_on page1.name
        wait_for_all_ckeditors_ready
        expect(page).to have_css("#workflow_route", text: I18n.t("mongoid.attributes.workflow/model/route.my_group"))

        click_on I18n.t("ss.links.edit")
        wait_for_all_ckeditors_ready
        within "form#item-form" do
          wait_for_cbox_opened { click_on I18n.t("ss.buttons.withdraw") }
        end
        within_cbox do
          click_on I18n.t("ss.buttons.ignore_alert")
        end
        wait_for_notice I18n.t("ss.notice.saved")

        Article::Page.find(page1.id).tap do |after_page|
          expect(after_page.state).to eq "closed"
        end
      end
    end

    context "when page is closed in index view" do
      let!(:minimum_close_permissions) do
        %w(read_private_cms_nodes read_private_article_pages close_private_article_pages)
      end

      it do
        login_user user1
        visit article_pages_path(site: site, cid: node)
        expect(page).to have_css(".list-item[data-id='#{page1.id}']", text: page1.name)

        within ".list-item[data-id='#{page1.id}']" do
          first("[type='checkbox']").click
        end
        within ".list-head" do
          click_on I18n.t("ss.links.make_them_close")
        end

        within "form" do
          expect(page).to have_css("[data-id='#{page1.id}'] [type='checkbox']")
          click_on I18n.t("ss.links.make_them_close")
        end
        wait_for_notice I18n.t("ss.notice.depublished")

        Article::Page.find(page1.id).tap do |after_page|
          expect(after_page.state).to eq "closed"
        end
      end
    end
  end
end
