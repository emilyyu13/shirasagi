require 'spec_helper'

describe Sys::SiteCopyJob, dbscope: :example do
  describe "copy kana dictionary" do
    let(:site) { cms_site }
    let(:task) { Sys::SiteCopyTask.new }
    let(:target_host_name) { unique_id }
    let(:target_host_host) { unique_id }
    let(:target_host_domain) { "#{unique_id}.example.jp" }
    let!(:dic) { create :kana_dictionary }

    before do
      task.target_host_name = target_host_name
      task.target_host_host = target_host_host
      task.target_host_domains = [ target_host_domain ]
      task.source_site_id = site.id
      task.copy_contents = ""
      task.save!
    end

    describe "without options" do
      before do
        perform_enqueued_jobs do
          ss_perform_now Sys::SiteCopyJob
        end
      end

      it do
        expect(Kana::Dictionary.site(site).count).to eq 1
        dest_site = Cms::Site.find_by(host: target_host_host)
        expect(Kana::Dictionary.site(dest_site).count).to eq 0
      end
    end

    describe "with options" do
      context "typical case" do
        before do
          task.copy_contents = "dictionaries"
          task.save!

          perform_enqueued_jobs do
            ss_perform_now Sys::SiteCopyJob
          end
        end

        it do
          dest_site = Cms::Site.find_by(host: target_host_host)
          expect(Kana::Dictionary.site(dest_site).count).to eq 1
          dest_dic = Kana::Dictionary.site(dest_site).first
          expect(dest_dic.name).to eq dic.name
          expect(dest_dic.body).to eq dic.body
        end
      end

      context "with deprecated attributes like permission_level" do
        before do
          # dic.set(permission_level: 3)
          dic.collection.update_one({ _id: dic.id }, { '$set' => { permission_level: 3 } })

          task.copy_contents = "dictionaries"
          task.save!

          perform_enqueued_jobs do
            ss_perform_now Sys::SiteCopyJob
          end
        end

        it do
          dest_site = Cms::Site.find_by(host: target_host_host)
          expect(Kana::Dictionary.site(dest_site).count).to eq 1
          dest_dic = Kana::Dictionary.site(dest_site).first
          expect(dest_dic.name).to eq dic.name
          expect(dest_dic.body).to eq dic.body
        end
      end
    end
  end
end
