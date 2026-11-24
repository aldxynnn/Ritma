-- =============================================================================
-- Migration 000700: Trainer Display Name & Automatic User Notification Hooks
--
-- 1. Adds `display_name` to `public.trainer_profiles` so trainer rosters and
--    PT session schedules show human-readable coach names without exposing
--    private `user_profiles` rows to all branch members.
-- 2. Populates `public.user_notifications` automatically via SECURITY DEFINER
--    triggers when a linked member receives an active subscription or confirms/
--    waitlists/promotes in a class booking.
-- =============================================================================

ALTER TABLE public.trainer_profiles
  ADD COLUMN IF NOT EXISTS display_name text NOT NULL DEFAULT '';

-- Notify linked members when a new subscription is provisioned.
CREATE OR REPLACE FUNCTION private.notify_on_subscription_created()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_user_id uuid;
  v_package_name text;
BEGIN
  SELECT m.user_id INTO v_user_id
  FROM public.members m
  WHERE m.id = NEW.member_id
    AND m.organization_id = NEW.organization_id;

  IF v_user_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT p.name INTO v_package_name
  FROM public.packages p
  WHERE p.id = NEW.package_id
    AND p.organization_id = NEW.organization_id;

  INSERT INTO public.user_notifications (
    organization_id, user_id, title, body, category, metadata
  ) VALUES (
    NEW.organization_id,
    v_user_id,
    'Membership Activated',
    'Your ' || COALESCE(NULLIF(trim(v_package_name), ''), 'fitness package') || ' pass is now active.',
    'membership',
    jsonb_build_object('subscription_id', NEW.id, 'package_id', NEW.package_id)
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_subscription_created ON public.member_subscriptions;
CREATE TRIGGER trg_notify_subscription_created
  AFTER INSERT ON public.member_subscriptions
  FOR EACH ROW EXECUTE FUNCTION private.notify_on_subscription_created();

-- Notify linked members on class booking creation or waitlist promotion.
CREATE OR REPLACE FUNCTION private.notify_on_booking_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_user_id uuid;
  v_session_title text;
  v_title text;
  v_body text;
BEGIN
  IF TG_OP = 'UPDATE' THEN
    IF NOT (OLD.status = 'waitlisted' AND NEW.status = 'confirmed') THEN
      RETURN NEW;
    END IF;
  ELSIF TG_OP = 'INSERT' THEN
    IF NEW.status NOT IN ('confirmed', 'waitlisted') THEN
      RETURN NEW;
    END IF;
  ELSE
    RETURN NEW;
  END IF;

  SELECT m.user_id INTO v_user_id
  FROM public.members m
  WHERE m.id = NEW.member_id
    AND m.organization_id = NEW.organization_id;

  IF v_user_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT cs.title INTO v_session_title
  FROM public.class_sessions cs
  WHERE cs.id = NEW.session_id
    AND cs.organization_id = NEW.organization_id;

  IF TG_OP = 'UPDATE' THEN
    v_title := 'Waitlist Seat Confirmed';
    v_body := 'A spot opened up and your seat for "' ||
      COALESCE(NULLIF(trim(v_session_title), ''), 'class') || '" is now confirmed.';
  ELSIF NEW.status = 'waitlisted' THEN
    v_title := 'Added to Class Waitlist';
    v_body := 'You are #' || COALESCE(NEW.waitlist_position::text, '-') ||
      ' on the waitlist for "' || COALESCE(NULLIF(trim(v_session_title), ''), 'class') || '".';
  ELSE
    v_title := 'Class Booking Confirmed';
    v_body := 'Your seat for "' ||
      COALESCE(NULLIF(trim(v_session_title), ''), 'class') || '" is confirmed.';
  END IF;

  INSERT INTO public.user_notifications (
    organization_id, user_id, title, body, category, metadata
  ) VALUES (
    NEW.organization_id,
    v_user_id,
    v_title,
    v_body,
    'booking',
    jsonb_build_object(
      'booking_id', NEW.id,
      'session_id', NEW.session_id,
      'status', NEW.status
    )
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_booking_created ON public.class_bookings;
CREATE TRIGGER trg_notify_booking_created
  AFTER INSERT ON public.class_bookings
  FOR EACH ROW EXECUTE FUNCTION private.notify_on_booking_change();

DROP TRIGGER IF EXISTS trg_notify_booking_promoted ON public.class_bookings;
CREATE TRIGGER trg_notify_booking_promoted
  AFTER UPDATE OF status ON public.class_bookings
  FOR EACH ROW EXECUTE FUNCTION private.notify_on_booking_change();

REVOKE ALL ON FUNCTION private.notify_on_subscription_created() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION private.notify_on_booking_change() FROM PUBLIC, anon, authenticated;
