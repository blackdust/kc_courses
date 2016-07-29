module KcCourses
  class Engine < ::Rails::Engine
    isolate_namespace KcCourses
    config.to_prepare do
      ApplicationController.helper ::ApplicationHelper

      Dir.glob(Rails.root + "app/decorators/kc_courses/**/*_decorator.rb").each do |c|
        require_dependency(c)
      end

      User.class_eval do
        has_many :courses, class_name: 'KcCourses::Course'
        has_many :chapters, class_name: 'KcCourses::Chapter'
        has_many :wares, class_name: 'KcCourses::Ware'
        has_many :course_joins, class_name: 'KcCourses::CourseJoin'
        has_many :ware_readings, class_name: 'KcCourses::WareReading'
        has_many :ware_reading_deltas, class_name: 'KcCourses::WareReadingDelta'
        has_many :favorites, class_name: 'KcCourses::Favorite'

        define_method :set_favorite_course do |course|
          unless self.favorites.where(course: course).any?
            self.favorites.create course: course
          end
        end

        define_method :cancel_favorite_course do |course|
          self.favorites.where(course: course).destroy_all > 0 ? true : false
        end

        define_method :favorite_courses do |&block|
          self.favorites.map{|x| x.course}
        end


        define_method :join_course do |course|
          return if course.class.name != 'KcCourses::Course'
          unless self.course_joins.where(course: course).any?
            self.course_joins.create course: course
          end
        end

        define_method :cancel_join_course do |course|
          course_joins.where(course: course).destroy_all > 0 ? true : false
        end

        define_method :join_courses do |&block|
          if block.blank?
            joins = self.course_joins
          else
            joins = block.call self.course_joins
          end
          join_ids = joins.map{|join|join.course_id.to_s}
          KcCourses::Course.where(:id.in => join_ids)
        end

        # 查询该用户某段时间内的学习情况
        define_method :read_status_of_course do |start_time, end_time|
          if ware_reading_deltas.count != 0
            arr = []
            ware_reading_deltas.map do |ware_reading_delta|
              if ware_reading_delta.time >= start_time.beginning_of_day && ware_reading_delta.time <= end_time.beginning_of_day
                arr << ware_reading_delta
              end
            end.compact
            return arr
          else
            return []
          end
        end
      end
    end
  end
end
