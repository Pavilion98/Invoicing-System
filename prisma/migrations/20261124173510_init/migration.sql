-- CreateEnum
CREATE TYPE "invoice_lifecycle" AS ENUM ('draft', 'sent', 'void');

-- CreateEnum
CREATE TYPE "payment_method" AS ENUM ('bank_transfer', 'cash', 'other');

-- CreateEnum
CREATE TYPE "reminder_stage" AS ENUM ('before_due_3_days', 'due_date', 'after_due_7_days', 'after_due_14_days');

-- CreateEnum
CREATE TYPE "reminder_delivery_status" AS ENUM ('pending', 'processing', 'sent', 'skipped', 'cancelled', 'failed');

-- CreateEnum
CREATE TYPE "email_purpose" AS ENUM ('invoice_initial', 'invoice_resend', 'reminder');

-- CreateEnum
CREATE TYPE "email_attempt_status" AS ENUM ('queued', 'accepted', 'failed');

-- CreateEnum
CREATE TYPE "job_run_status" AS ENUM ('running', 'succeeded', 'partially_failed', 'failed');

-- CreateEnum
CREATE TYPE "invoice_event_type" AS ENUM ('invoice_created', 'invoice_sent', 'email_attempt_failed', 'invoice_resent', 'reminder_skipped', 'reminder_sent', 'payment_recorded', 'payment_reversed', 'invoice_voided');

-- CreateEnum
CREATE TYPE "operational_alert_status" AS ENUM ('open', 'dismissed', 'resolved');

-- CreateEnum
CREATE TYPE "retainer_billing_status" AS ENUM ('pending', 'invoice_created', 'sent', 'skipped', 'failed');

-- CreateTable
CREATE TABLE "owner_users" (
    "id" SMALLINT NOT NULL DEFAULT 1,
    "email" VARCHAR(254) NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "last_login_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "owner_users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "password_reset_tokens" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "owner_user_id" SMALLINT NOT NULL,
    "token_hash" VARCHAR(255) NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "used_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "password_reset_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_sessions" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "owner_user_id" SMALLINT NOT NULL,
    "session_token_hash" VARCHAR(255) NOT NULL,
    "last_activity_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "revoked_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "auth_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "studio_settings" (
    "id" SMALLINT NOT NULL DEFAULT 1,
    "studio_name" VARCHAR(200) NOT NULL,
    "studio_address" TEXT,
    "studio_phone" VARCHAR(50),
    "studio_email" VARCHAR(254),
    "vat_number" VARCHAR(100),
    "logo_storage_key" VARCHAR(500),
    "logo_content_type" VARCHAR(50),
    "logo_size_bytes" INTEGER,
    "payment_instructions" TEXT,
    "sender_name" VARCHAR(200),
    "sender_email" VARCHAR(254),
    "reply_to_email" VARCHAR(254),
    "timezone" VARCHAR(64) NOT NULL DEFAULT 'Asia/Beirut',
    "updated_by_user_id" SMALLINT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "studio_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "clients" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "contact_name" VARCHAR(200) NOT NULL,
    "company_name" VARCHAR(200),
    "email" VARCHAR(254) NOT NULL,
    "phone" VARCHAR(50),
    "billing_address" TEXT,
    "default_payment_terms_days" INTEGER NOT NULL DEFAULT 0,
    "archived_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "clients_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice_number_counters" (
    "calendar_year" SMALLINT NOT NULL,
    "last_sequence" INTEGER NOT NULL DEFAULT 0,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "invoice_number_counters_pkey" PRIMARY KEY ("calendar_year")
);

-- CreateTable
CREATE TABLE "invoices" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "client_id" UUID NOT NULL,
    "retainer_billing_id" UUID,
    "invoice_number" VARCHAR(13),
    "lifecycle" "invoice_lifecycle" NOT NULL DEFAULT 'draft',
    "issue_date" DATE NOT NULL,
    "due_date" DATE NOT NULL,
    "currency_code" CHAR(3) NOT NULL DEFAULT 'USD',
    "vat_enabled" BOOLEAN NOT NULL DEFAULT false,
    "vat_rate_basis_points" INTEGER NOT NULL DEFAULT 1100,
    "subtotal_cents" BIGINT NOT NULL DEFAULT 0,
    "vat_cents" BIGINT NOT NULL DEFAULT 0,
    "total_cents" BIGINT NOT NULL DEFAULT 0,
    "notes" TEXT,
    "sent_at" TIMESTAMPTZ(6),
    "sent_to_email" VARCHAR(254),
    "sent_pdf_storage_key" VARCHAR(500),
    "sent_pdf_sha256" CHAR(64),
    "sent_pdf_generated_at" TIMESTAMPTZ(6),
    "voided_at" TIMESTAMPTZ(6),
    "voided_by_user_id" SMALLINT,
    "void_reason" TEXT,
    "created_by_user_id" SMALLINT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "invoices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice_line_items" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "invoice_id" UUID NOT NULL,
    "line_number" INTEGER NOT NULL,
    "description" TEXT NOT NULL,
    "quantity" DECIMAL(18,6) NOT NULL,
    "unit_price_cents" BIGINT NOT NULL,
    "line_total_cents" BIGINT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "invoice_line_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice_snapshots" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "invoice_id" UUID NOT NULL,
    "studio_name" VARCHAR(200) NOT NULL,
    "studio_address" TEXT,
    "studio_phone" VARCHAR(50),
    "studio_email" VARCHAR(254),
    "studio_vat_number" VARCHAR(100),
    "studio_logo_storage_key" VARCHAR(500),
    "payment_instructions" TEXT,
    "client_contact_name" VARCHAR(200) NOT NULL,
    "client_company_name" VARCHAR(200),
    "client_email" VARCHAR(254) NOT NULL,
    "client_phone" VARCHAR(50),
    "client_billing_address" TEXT,
    "snapshot_created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "invoice_snapshots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice_pdf_access_tokens" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "invoice_id" UUID NOT NULL,
    "token_hash" VARCHAR(255) NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "redeemed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "invoice_pdf_access_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payments" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "invoice_id" UUID NOT NULL,
    "amount_cents" BIGINT NOT NULL,
    "payment_date" DATE NOT NULL,
    "method" "payment_method" NOT NULL,
    "recorded_by_user_id" SMALLINT,
    "recorded_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "note" TEXT,

    CONSTRAINT "payments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payment_reversals" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "payment_id" UUID NOT NULL,
    "reversed_by_user_id" SMALLINT,
    "reversed_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reason" TEXT,

    CONSTRAINT "payment_reversals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reminder_deliveries" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "invoice_id" UUID NOT NULL,
    "stage" "reminder_stage" NOT NULL,
    "scheduled_for" TIMESTAMPTZ(6) NOT NULL,
    "status" "reminder_delivery_status" NOT NULL DEFAULT 'pending',
    "sent_at" TIMESTAMPTZ(6),
    "skipped_at" TIMESTAMPTZ(6),
    "skip_reason" VARCHAR(300),
    "cancelled_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reminder_deliveries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "email_attempts" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "invoice_id" UUID NOT NULL,
    "reminder_delivery_id" UUID,
    "purpose" "email_purpose" NOT NULL,
    "recipient_email" VARCHAR(254) NOT NULL,
    "sender_name" VARCHAR(200),
    "sender_email" VARCHAR(254),
    "reply_to_email" VARCHAR(254),
    "subject" VARCHAR(500) NOT NULL,
    "body" TEXT,
    "attachment_storage_key" VARCHAR(500),
    "provider_name" VARCHAR(100),
    "provider_message_id" VARCHAR(255),
    "status" "email_attempt_status" NOT NULL DEFAULT 'queued',
    "attempted_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "accepted_at" TIMESTAMPTZ(6),
    "failure_code" VARCHAR(150),
    "failure_message" TEXT,

    CONSTRAINT "email_attempts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice_events" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "invoice_id" UUID NOT NULL,
    "actor_user_id" SMALLINT,
    "event_type" "invoice_event_type" NOT NULL,
    "payment_id" UUID,
    "email_attempt_id" UUID,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "details" JSONB,

    CONSTRAINT "invoice_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "job_runs" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "job_name" VARCHAR(100) NOT NULL,
    "scheduled_for" TIMESTAMPTZ(6),
    "started_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "finished_at" TIMESTAMPTZ(6),
    "status" "job_run_status" NOT NULL DEFAULT 'running',
    "processed_count" INTEGER NOT NULL DEFAULT 0,
    "error_summary" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "job_runs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "operational_alerts" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "email_attempt_id" UUID,
    "job_run_id" UUID,
    "status" "operational_alert_status" NOT NULL DEFAULT 'open',
    "message" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "dismissed_at" TIMESTAMPTZ(6),
    "dismissed_by_user_id" SMALLINT,
    "resolved_at" TIMESTAMPTZ(6),

    CONSTRAINT "operational_alerts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "client_reminder_settings" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "client_id" UUID NOT NULL,
    "is_paused" BOOLEAN NOT NULL DEFAULT false,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "client_reminder_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "client_reminder_pause_periods" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "client_id" UUID NOT NULL,
    "paused_at" TIMESTAMPTZ(6) NOT NULL,
    "resumed_at" TIMESTAMPTZ(6),
    "paused_by_user_id" SMALLINT,
    "resumed_by_user_id" SMALLINT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "client_reminder_pause_periods_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reminder_templates" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "stage" "reminder_stage" NOT NULL,
    "subject_template" VARCHAR(500) NOT NULL,
    "body_template" TEXT NOT NULL,
    "updated_by_user_id" SMALLINT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reminder_templates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "retainers" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "client_id" UUID NOT NULL,
    "billing_day" INTEGER NOT NULL,
    "start_date" DATE NOT NULL,
    "end_date" DATE,
    "vat_enabled" BOOLEAN NOT NULL DEFAULT false,
    "vat_rate_basis_points" INTEGER NOT NULL DEFAULT 1100,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_by_user_id" SMALLINT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "retainers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "retainer_line_items" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "retainer_id" UUID NOT NULL,
    "line_number" INTEGER NOT NULL,
    "description" TEXT NOT NULL,
    "quantity" DECIMAL(18,6) NOT NULL,
    "unit_price_cents" BIGINT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "retainer_line_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "retainer_pauses" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "retainer_id" UUID NOT NULL,
    "paused_from" DATE NOT NULL,
    "resumed_on" DATE,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "retainer_pauses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "retainer_billings" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "retainer_id" UUID NOT NULL,
    "billing_month" DATE NOT NULL,
    "scheduled_for" TIMESTAMPTZ(6) NOT NULL,
    "status" "retainer_billing_status" NOT NULL DEFAULT 'pending',
    "processed_at" TIMESTAMPTZ(6),
    "skip_reason" VARCHAR(300),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "retainer_billings_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "owner_users_email_key" ON "owner_users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "password_reset_tokens_token_hash_key" ON "password_reset_tokens"("token_hash");

-- CreateIndex
CREATE INDEX "password_reset_tokens_owner_user_id_idx" ON "password_reset_tokens"("owner_user_id");

-- CreateIndex
CREATE INDEX "password_reset_tokens_expires_at_idx" ON "password_reset_tokens"("expires_at");

-- CreateIndex
CREATE UNIQUE INDEX "auth_sessions_session_token_hash_key" ON "auth_sessions"("session_token_hash");

-- CreateIndex
CREATE INDEX "auth_sessions_owner_user_id_idx" ON "auth_sessions"("owner_user_id");

-- CreateIndex
CREATE INDEX "auth_sessions_expires_at_idx" ON "auth_sessions"("expires_at");

-- CreateIndex
CREATE INDEX "clients_email_idx" ON "clients"("email");

-- CreateIndex
CREATE INDEX "clients_archived_at_idx" ON "clients"("archived_at");

-- CreateIndex
CREATE UNIQUE INDEX "invoices_retainer_billing_id_key" ON "invoices"("retainer_billing_id");

-- CreateIndex
CREATE UNIQUE INDEX "invoices_invoice_number_key" ON "invoices"("invoice_number");

-- CreateIndex
CREATE INDEX "invoices_client_id_idx" ON "invoices"("client_id");

-- CreateIndex
CREATE INDEX "invoices_lifecycle_due_date_idx" ON "invoices"("lifecycle", "due_date");

-- CreateIndex
CREATE INDEX "invoices_sent_at_idx" ON "invoices"("sent_at");

-- CreateIndex
CREATE INDEX "invoices_created_at_idx" ON "invoices"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "invoice_line_items_invoice_id_line_number_key" ON "invoice_line_items"("invoice_id", "line_number");

-- CreateIndex
CREATE UNIQUE INDEX "invoice_snapshots_invoice_id_key" ON "invoice_snapshots"("invoice_id");

-- CreateIndex
CREATE UNIQUE INDEX "invoice_pdf_access_tokens_token_hash_key" ON "invoice_pdf_access_tokens"("token_hash");

-- CreateIndex
CREATE INDEX "invoice_pdf_access_tokens_invoice_id_idx" ON "invoice_pdf_access_tokens"("invoice_id");

-- CreateIndex
CREATE INDEX "invoice_pdf_access_tokens_expires_at_idx" ON "invoice_pdf_access_tokens"("expires_at");

-- CreateIndex
CREATE INDEX "payments_invoice_id_idx" ON "payments"("invoice_id");

-- CreateIndex
CREATE INDEX "payments_payment_date_idx" ON "payments"("payment_date");

-- CreateIndex
CREATE INDEX "payments_recorded_at_idx" ON "payments"("recorded_at");

-- CreateIndex
CREATE UNIQUE INDEX "payment_reversals_payment_id_key" ON "payment_reversals"("payment_id");

-- CreateIndex
CREATE INDEX "reminder_deliveries_status_scheduled_for_idx" ON "reminder_deliveries"("status", "scheduled_for");

-- CreateIndex
CREATE UNIQUE INDEX "reminder_deliveries_invoice_id_stage_key" ON "reminder_deliveries"("invoice_id", "stage");

-- CreateIndex
CREATE INDEX "email_attempts_invoice_id_idx" ON "email_attempts"("invoice_id");

-- CreateIndex
CREATE INDEX "email_attempts_reminder_delivery_id_idx" ON "email_attempts"("reminder_delivery_id");

-- CreateIndex
CREATE INDEX "email_attempts_status_attempted_at_idx" ON "email_attempts"("status", "attempted_at");

-- CreateIndex
CREATE INDEX "email_attempts_attempted_at_idx" ON "email_attempts"("attempted_at");

-- CreateIndex
CREATE INDEX "invoice_events_invoice_id_occurred_at_idx" ON "invoice_events"("invoice_id", "occurred_at");

-- CreateIndex
CREATE INDEX "invoice_events_event_type_idx" ON "invoice_events"("event_type");

-- CreateIndex
CREATE INDEX "job_runs_job_name_started_at_idx" ON "job_runs"("job_name", "started_at");

-- CreateIndex
CREATE INDEX "job_runs_status_started_at_idx" ON "job_runs"("status", "started_at");

-- CreateIndex
CREATE UNIQUE INDEX "operational_alerts_email_attempt_id_key" ON "operational_alerts"("email_attempt_id");

-- CreateIndex
CREATE UNIQUE INDEX "operational_alerts_job_run_id_key" ON "operational_alerts"("job_run_id");

-- CreateIndex
CREATE INDEX "operational_alerts_status_created_at_idx" ON "operational_alerts"("status", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "client_reminder_settings_client_id_key" ON "client_reminder_settings"("client_id");

-- CreateIndex
CREATE INDEX "client_reminder_pause_periods_client_id_paused_at_idx" ON "client_reminder_pause_periods"("client_id", "paused_at");

-- CreateIndex
CREATE UNIQUE INDEX "uq_client_reminder_pause_one_open_per_client" ON "client_reminder_pause_periods"("client_id") WHERE (resumed_at IS NULL);

-- CreateIndex
CREATE UNIQUE INDEX "reminder_templates_stage_key" ON "reminder_templates"("stage");

-- CreateIndex
CREATE INDEX "retainers_client_id_idx" ON "retainers"("client_id");

-- CreateIndex
CREATE INDEX "retainers_is_active_start_date_end_date_idx" ON "retainers"("is_active", "start_date", "end_date");

-- CreateIndex
CREATE UNIQUE INDEX "retainer_line_items_retainer_id_line_number_key" ON "retainer_line_items"("retainer_id", "line_number");

-- CreateIndex
CREATE INDEX "retainer_pauses_retainer_id_paused_from_idx" ON "retainer_pauses"("retainer_id", "paused_from");

-- CreateIndex
CREATE UNIQUE INDEX "uq_retainer_pause_one_open_per_retainer" ON "retainer_pauses"("retainer_id") WHERE (resumed_on IS NULL);

-- CreateIndex
CREATE INDEX "retainer_billings_status_scheduled_for_idx" ON "retainer_billings"("status", "scheduled_for");

-- CreateIndex
CREATE UNIQUE INDEX "retainer_billings_retainer_id_billing_month_key" ON "retainer_billings"("retainer_id", "billing_month");

-- AddForeignKey
ALTER TABLE "password_reset_tokens" ADD CONSTRAINT "password_reset_tokens_owner_user_id_fkey" FOREIGN KEY ("owner_user_id") REFERENCES "owner_users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auth_sessions" ADD CONSTRAINT "auth_sessions_owner_user_id_fkey" FOREIGN KEY ("owner_user_id") REFERENCES "owner_users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "studio_settings" ADD CONSTRAINT "studio_settings_updated_by_user_id_fkey" FOREIGN KEY ("updated_by_user_id") REFERENCES "owner_users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoices" ADD CONSTRAINT "invoices_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "clients"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoices" ADD CONSTRAINT "invoices_retainer_billing_id_fkey" FOREIGN KEY ("retainer_billing_id") REFERENCES "retainer_billings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoices" ADD CONSTRAINT "invoices_voided_by_user_id_fkey" FOREIGN KEY ("voided_by_user_id") REFERENCES "owner_users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoices" ADD CONSTRAINT "invoices_created_by_user_id_fkey" FOREIGN KEY ("created_by_user_id") REFERENCES "owner_users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice_line_items" ADD CONSTRAINT "invoice_line_items_invoice_id_fkey" FOREIGN KEY ("invoice_id") REFERENCES "invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice_snapshots" ADD CONSTRAINT "invoice_snapshots_invoice_id_fkey" FOREIGN KEY ("invoice_id") REFERENCES "invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice_pdf_access_tokens" ADD CONSTRAINT "invoice_pdf_access_tokens_invoice_id_fkey" FOREIGN KEY ("invoice_id") REFERENCES "invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_invoice_id_fkey" FOREIGN KEY ("invoice_id") REFERENCES "invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_recorded_by_user_id_fkey" FOREIGN KEY ("recorded_by_user_id") REFERENCES "owner_users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_reversals" ADD CONSTRAINT "payment_reversals_payment_id_fkey" FOREIGN KEY ("payment_id") REFERENCES "payments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_reversals" ADD CONSTRAINT "payment_reversals_reversed_by_user_id_fkey" FOREIGN KEY ("reversed_by_user_id") REFERENCES "owner_users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reminder_deliveries" ADD CONSTRAINT "reminder_deliveries_invoice_id_fkey" FOREIGN KEY ("invoice_id") REFERENCES "invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "email_attempts" ADD CONSTRAINT "email_attempts_invoice_id_fkey" FOREIGN KEY ("invoice_id") REFERENCES "invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "email_attempts" ADD CONSTRAINT "email_attempts_reminder_delivery_id_fkey" FOREIGN KEY ("reminder_delivery_id") REFERENCES "reminder_deliveries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice_events" ADD CONSTRAINT "invoice_events_invoice_id_fkey" FOREIGN KEY ("invoice_id") REFERENCES "invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice_events" ADD CONSTRAINT "invoice_events_actor_user_id_fkey" FOREIGN KEY ("actor_user_id") REFERENCES "owner_users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice_events" ADD CONSTRAINT "invoice_events_payment_id_fkey" FOREIGN KEY ("payment_id") REFERENCES "payments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice_events" ADD CONSTRAINT "invoice_events_email_attempt_id_fkey" FOREIGN KEY ("email_attempt_id") REFERENCES "email_attempts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "operational_alerts" ADD CONSTRAINT "operational_alerts_email_attempt_id_fkey" FOREIGN KEY ("email_attempt_id") REFERENCES "email_attempts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "operational_alerts" ADD CONSTRAINT "operational_alerts_job_run_id_fkey" FOREIGN KEY ("job_run_id") REFERENCES "job_runs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "operational_alerts" ADD CONSTRAINT "operational_alerts_dismissed_by_user_id_fkey" FOREIGN KEY ("dismissed_by_user_id") REFERENCES "owner_users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "client_reminder_settings" ADD CONSTRAINT "client_reminder_settings_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "clients"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "client_reminder_pause_periods" ADD CONSTRAINT "client_reminder_pause_periods_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "clients"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "client_reminder_pause_periods" ADD CONSTRAINT "client_reminder_pause_periods_paused_by_user_id_fkey" FOREIGN KEY ("paused_by_user_id") REFERENCES "owner_users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "client_reminder_pause_periods" ADD CONSTRAINT "client_reminder_pause_periods_resumed_by_user_id_fkey" FOREIGN KEY ("resumed_by_user_id") REFERENCES "owner_users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reminder_templates" ADD CONSTRAINT "reminder_templates_updated_by_user_id_fkey" FOREIGN KEY ("updated_by_user_id") REFERENCES "owner_users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "retainers" ADD CONSTRAINT "retainers_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "clients"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "retainers" ADD CONSTRAINT "retainers_created_by_user_id_fkey" FOREIGN KEY ("created_by_user_id") REFERENCES "owner_users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "retainer_line_items" ADD CONSTRAINT "retainer_line_items_retainer_id_fkey" FOREIGN KEY ("retainer_id") REFERENCES "retainers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "retainer_pauses" ADD CONSTRAINT "retainer_pauses_retainer_id_fkey" FOREIGN KEY ("retainer_id") REFERENCES "retainers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "retainer_billings" ADD CONSTRAINT "retainer_billings_retainer_id_fkey" FOREIGN KEY ("retainer_id") REFERENCES "retainers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
