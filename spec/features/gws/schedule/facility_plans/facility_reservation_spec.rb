require 'spec_helper'

describe "gws_schedule_facility_plans", type: :feature, dbscope: :example, js: true do
  let(:site) { gws_site }
  let(:facility) { create :gws_facility_item }
  let(:start_at) { Time.zone.now.change(day: 4, hour: 10, minute: 0, second: 0) }
  let(:time) { start_at + 1.hour }

  describe "what facility_reservation is" do
    before do
      Timecop.travel(time)
      login_gws_user
    end

    after { Timecop.return }

    context "without plan" do
      it do
        visit gws_schedule_facility_plans_path(site: site, facility: facility)
        click_on I18n.t("gws/schedule.links.add_plan")
        wait_for_js_ready
        within "form#item-form" do
          wait_for_cbox_opened { click_on I18n.t('gws/schedule.facility_reservation.index') }
        end
        within_cbox do
          expect(page).to have_css(".reservation-valid", text: I18n.t('gws/schedule.facility_reservation.free'))
          expect(page).to have_css(".reservation.free")
          expect(page).to have_no_css(".reservation.exist")
          expect(page).to have_no_css(".reservation.registered")
        end
      end
    end

    context "with simple plan" do
      let!(:item) do
        create(:gws_schedule_plan, facility_ids: [ facility.id ])
      end

      it do
        visit gws_schedule_facility_plan_path(site: site, facility: facility, id: item)
        click_on I18n.t("ss.links.edit")
        wait_for_js_ready
        within "form#item-form" do
          wait_for_cbox_opened { click_on I18n.t('gws/schedule.facility_reservation.index') }
        end
        within_cbox do
          expect(page).to have_css(".reservation-valid", text: I18n.t('gws/schedule.facility_reservation.free'))
          expect(page).to have_css(".reservation.free")
          expect(page).to have_no_css(".reservation.exist")
          expect(page).to have_no_css(".reservation.registered")
        end
      end
    end

    context "with multi-days plan" do
      let(:end_at) { start_at + 3.days }
      let!(:item) do
        create(:gws_schedule_plan, facility_ids: [ facility.id ], start_at: start_at, end_at: end_at)
      end

      it do
        visit gws_schedule_facility_plan_path(site: site, facility: facility, id: item)
        click_on I18n.t("ss.links.edit")
        wait_for_js_ready
        within "form#item-form" do
          wait_for_cbox_opened { click_on I18n.t('gws/schedule.facility_reservation.index') }
        end
        within_cbox do
          expect(page).to have_css(".reservation-valid", text: I18n.t('gws/schedule.facility_reservation.free'))
          expect(page).to have_css(".reservation.free")
          expect(page).to have_no_css(".reservation.exist")
          expect(page).to have_no_css(".reservation.registered")
        end
      end
    end

    context "with multi-days and repeated plan" do
      let(:end_at) { start_at + 3.days }
      let(:repeat_start) { start_at.beginning_of_month }
      let(:repeat_end) { repeat_start + 12.months }
      let!(:item) do
        create(
          :gws_schedule_plan, facility_ids: [ facility.id ], start_at: start_at, end_at: end_at,
          repeat_type: "monthly", interval: 1, repeat_base: "date",
          repeat_start: repeat_start, repeat_end: repeat_end, wdays: []
        )
      end

      it do
        visit gws_schedule_facility_plan_path(site: site, facility: facility, id: item)
        click_on I18n.t("ss.links.edit")
        wait_for_js_ready
        within "form#item-form" do
          wait_for_cbox_opened { click_on I18n.t('gws/schedule.facility_reservation.index') }
        end
        within_cbox do
          expect(page).to have_css(".reservation-valid", text: I18n.t('gws/schedule.facility_reservation.free'))
          expect(page).to have_css(".reservation.free")
          expect(page).to have_no_css(".reservation.exist")
          expect(page).to have_css(".reservation.registered")
        end
      end
    end
  end
end
