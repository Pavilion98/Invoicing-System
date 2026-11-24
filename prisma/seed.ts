import "dotenv/config";
import { PrismaClient } from "../generated/prisma/client";
import { PrismaPg } from "@prisma/adapter-pg";

const prisma = new PrismaClient({
  adapter: new PrismaPg({ connectionString: process.env.DATABASE_URL }),
});

const demoId = (value: number) =>
  `00000000-0000-4000-8000-${value.toString().padStart(12, "0")}`;

const day = (offset: number) => {
  const date = new Date();
  date.setUTCHours(0, 0, 0, 0);
  date.setUTCDate(date.getUTCDate() + offset);
  return date;
};

const timestamp = (offsetDays: number) =>
  new Date(Date.now() + offsetDays * 24 * 60 * 60 * 1000);

const month = (offset: number) => {
  const date = new Date();
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth() + offset, 1));
};

async function main() {
  const currentYear = new Date().getUTCFullYear();

  await prisma.$transaction(async (tx) => {
    await tx.ownerUser.upsert({
      where: { id: 1 },
      create: {
        id: 1,
        email: "owner@haddad-studio.example",
        passwordHash: "SEED_ONLY_CHANGE_BEFORE_AUTHENTICATION",
      },
      update: { email: "owner@haddad-studio.example" },
    });

    await tx.studioSetting.upsert({
      where: { id: 1 },
      create: {
        id: 1,
        studioName: "Haddad Design Studio",
        studioAddress: "12 Cedar Avenue, Beirut, Lebanon",
        studioPhone: "+961 1 555 014",
        studioEmail: "billing@haddad-studio.example",
        vatNumber: "LB-DEMO-1042",
        paymentInstructions: "Bank transfer: Haddad Design Studio / Demo account",
        senderName: "Maya Haddad",
        senderEmail: "billing@haddad-studio.example",
        replyToEmail: "maya@haddad-studio.example",
        timezone: "Asia/Beirut",
        updatedByUserId: 1,
      },
      update: {
        studioName: "Haddad Design Studio",
        updatedByUserId: 1,
      },
    });

    await tx.client.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(101),
          contactName: "Nour Khoury",
          companyName: "Cedar & Stone Interiors",
          email: "nour@cedar-stone.example",
          phone: "+961 3 555 101",
          billingAddress: "Hamra, Beirut, Lebanon",
          defaultPaymentTermsDays: 30,
        },
        {
          id: demoId(102),
          contactName: "Karim Mansour",
          companyName: "Blue Fig Foods",
          email: "karim@bluefig.example",
          phone: "+961 3 555 102",
          billingAddress: "Mar Mikhael, Beirut, Lebanon",
          defaultPaymentTermsDays: 14,
        },
        {
          id: demoId(103),
          contactName: "Lina Saad",
          email: "lina@linasaad.example",
          billingAddress: "Byblos, Lebanon",
          defaultPaymentTermsDays: 7,
        },
        {
          id: demoId(104),
          contactName: "Omar Nassar",
          companyName: "Northwind Architecture",
          email: "omar@northwind.example",
          phone: "+961 3 555 104",
          billingAddress: "Achrafieh, Beirut, Lebanon",
          defaultPaymentTermsDays: 30,
          archivedAt: timestamp(-45),
        },
        {
          id: demoId(105),
          contactName: "Rana Daher",
          companyName: "Olive Branch Media",
          email: "rana@olivebranch.example",
          phone: "+961 3 555 105",
          billingAddress: "Jounieh, Lebanon",
          defaultPaymentTermsDays: 21,
        },
      ],
    });

    await tx.clientReminderSetting.createMany({
      skipDuplicates: true,
      data: [
        { id: demoId(301), clientId: demoId(101), isPaused: false },
        { id: demoId(302), clientId: demoId(102), isPaused: true },
        { id: demoId(303), clientId: demoId(103), isPaused: false },
        { id: demoId(304), clientId: demoId(105), isPaused: false },
      ],
    });

    await tx.clientReminderPausePeriod.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(311),
          clientId: demoId(101),
          pausedAt: timestamp(-60),
          resumedAt: timestamp(-50),
          pausedByUserId: 1,
          resumedByUserId: 1,
        },
        {
          id: demoId(312),
          clientId: demoId(102),
          pausedAt: timestamp(-12),
          pausedByUserId: 1,
        },
      ],
    });

    await tx.invoiceNumberCounter.upsert({
      where: { calendarYear: currentYear },
      create: { calendarYear: currentYear, lastSequence: 8 },
      update: { lastSequence: 8 },
    });

    await tx.passwordResetToken.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(401),
          ownerUserId: 1,
          tokenHash: "seed-expired-reset-token-hash",
          expiresAt: timestamp(-10),
        },
        {
          id: demoId(402),
          ownerUserId: 1,
          tokenHash: "seed-used-reset-token-hash",
          expiresAt: timestamp(2),
          usedAt: timestamp(-1),
        },
      ],
    });

    await tx.authSession.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(411),
          ownerUserId: 1,
          sessionTokenHash: "seed-active-session-token-hash",
          lastActivityAt: timestamp(-1),
          expiresAt: timestamp(14),
        },
        {
          id: demoId(412),
          ownerUserId: 1,
          sessionTokenHash: "seed-revoked-session-token-hash",
          lastActivityAt: timestamp(-8),
          expiresAt: timestamp(8),
          revokedAt: timestamp(-7),
        },
      ],
    });

    await tx.retainer.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(801),
          clientId: demoId(101),
          billingDay: 1,
          startDate: day(-150),
          vatEnabled: true,
          vatRateBasisPoints: 1100,
          createdByUserId: 1,
        },
        {
          id: demoId(802),
          clientId: demoId(103),
          billingDay: 15,
          startDate: day(-240),
          endDate: day(-30),
          isActive: false,
          createdByUserId: 1,
        },
        {
          id: demoId(803),
          clientId: demoId(105),
          billingDay: 28,
          startDate: day(-75),
          createdByUserId: 1,
        },
      ],
    });

    await tx.retainerLineItem.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(821),
          retainerId: demoId(801),
          lineNumber: 1,
          description: "Monthly brand design support",
          quantity: 8,
          unitPriceCents: 7500n,
        },
        {
          id: demoId(822),
          retainerId: demoId(801),
          lineNumber: 2,
          description: "Monthly social media assets",
          quantity: 4,
          unitPriceCents: 5000n,
        },
        {
          id: demoId(823),
          retainerId: demoId(802),
          lineNumber: 1,
          description: "Architecture visualization retainer",
          quantity: 1,
          unitPriceCents: 180000n,
        },
        {
          id: demoId(824),
          retainerId: demoId(803),
          lineNumber: 1,
          description: "Monthly campaign design",
          quantity: 1,
          unitPriceCents: 95000n,
        },
      ],
    });

    await tx.retainerPause.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(831),
          retainerId: demoId(801),
          pausedFrom: day(-40),
          resumedOn: day(-25),
        },
        {
          id: demoId(832),
          retainerId: demoId(803),
          pausedFrom: day(-5),
        },
      ],
    });

    await tx.retainerBilling.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(811),
          retainerId: demoId(801),
          billingMonth: month(-2),
          scheduledFor: timestamp(-60),
          status: "sent",
          processedAt: timestamp(-59),
        },
        {
          id: demoId(812),
          retainerId: demoId(801),
          billingMonth: month(-1),
          scheduledFor: timestamp(-30),
          status: "invoiceCreated",
          processedAt: timestamp(-29),
        },
        {
          id: demoId(813),
          retainerId: demoId(802),
          billingMonth: month(-1),
          scheduledFor: timestamp(-20),
          status: "skipped",
          processedAt: timestamp(-20),
          skipReason: "Retainer ended before this billing period",
        },
        {
          id: demoId(814),
          retainerId: demoId(803),
          billingMonth: month(0),
          scheduledFor: timestamp(-2),
          status: "failed",
          processedAt: timestamp(-2),
        },
        {
          id: demoId(815),
          retainerId: demoId(801),
          billingMonth: month(0),
          scheduledFor: timestamp(5),
          status: "pending",
        },
      ],
    });

    await tx.invoice.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(201),
          clientId: demoId(101),
          invoiceNumber: null,
          lifecycle: "draft",
          issueDate: day(-2),
          dueDate: day(28),
          currencyCode: "USD",
          subtotalCents: 240000n,
          vatCents: 0n,
          totalCents: 240000n,
          notes: "Draft invoice awaiting review.",
          createdByUserId: 1,
        },
        {
          id: demoId(202),
          clientId: demoId(102),
          invoiceNumber: `INV-${currentYear}-0001`,
          lifecycle: "sent",
          issueDate: day(-48),
          dueDate: day(-18),
          currencyCode: "USD",
          vatEnabled: true,
          vatRateBasisPoints: 1100,
          subtotalCents: 550000n,
          vatCents: 60500n,
          totalCents: 610500n,
          sentAt: timestamp(-47),
          sentToEmail: "karim@bluefig.example",
          sentPdfStorageKey: "demo/invoices/cedar-0001.pdf",
          sentPdfSha256: "a".repeat(64),
          sentPdfGeneratedAt: timestamp(-47),
          createdByUserId: 1,
        },
        {
          id: demoId(203),
          clientId: demoId(103),
          invoiceNumber: `INV-${currentYear}-0002`,
          lifecycle: "sent",
          issueDate: day(-20),
          dueDate: day(10),
          currencyCode: "EUR",
          subtotalCents: 180000n,
          vatCents: 0n,
          totalCents: 180000n,
          sentAt: timestamp(-19),
          sentToEmail: "lina@linasaad.example",
          sentPdfStorageKey: "demo/invoices/lina-0002.pdf",
          sentPdfSha256: "b".repeat(64),
          sentPdfGeneratedAt: timestamp(-19),
          createdByUserId: 1,
        },
        {
          id: demoId(204),
          clientId: demoId(101),
          invoiceNumber: `INV-${currentYear}-0003`,
          lifecycle: "sent",
          issueDate: day(-75),
          dueDate: day(-45),
          currencyCode: "USD",
          vatEnabled: true,
          subtotalCents: 300000n,
          vatCents: 33000n,
          totalCents: 333000n,
          sentAt: timestamp(-74),
          sentToEmail: "nour@cedar-stone.example",
          sentPdfStorageKey: "demo/invoices/cedar-0003.pdf",
          sentPdfSha256: "c".repeat(64),
          sentPdfGeneratedAt: timestamp(-74),
          createdByUserId: 1,
        },
        {
          id: demoId(205),
          clientId: demoId(105),
          invoiceNumber: `INV-${currentYear}-0004`,
          lifecycle: "void",
          issueDate: day(-90),
          dueDate: day(-60),
          currencyCode: "USD",
          subtotalCents: 80000n,
          vatCents: 0n,
          totalCents: 80000n,
          voidedAt: timestamp(-58),
          voidedByUserId: 1,
          voidReason: "Duplicate invoice entered in error",
          createdByUserId: 1,
        },
        {
          id: demoId(206),
          clientId: demoId(102),
          invoiceNumber: `INV-${currentYear}-0005`,
          lifecycle: "sent",
          issueDate: day(-55),
          dueDate: day(-25),
          currencyCode: "USD",
          subtotalCents: 125000n,
          vatCents: 0n,
          totalCents: 125000n,
          sentAt: timestamp(-54),
          sentToEmail: "karim@bluefig.example",
          sentPdfStorageKey: "demo/invoices/bluefig-0005.pdf",
          sentPdfSha256: "d".repeat(64),
          sentPdfGeneratedAt: timestamp(-54),
          createdByUserId: 1,
        },
        {
          id: demoId(207),
          clientId: demoId(105),
          invoiceNumber: `INV-${currentYear}-0006`,
          lifecycle: "sent",
          issueDate: day(-8),
          dueDate: day(22),
          currencyCode: "USD",
          subtotalCents: 95000n,
          vatCents: 0n,
          totalCents: 95000n,
          sentAt: timestamp(-7),
          sentToEmail: "rana@olivebranch.example",
          sentPdfStorageKey: "demo/invoices/olive-0006.pdf",
          sentPdfSha256: "e".repeat(64),
          sentPdfGeneratedAt: timestamp(-7),
          createdByUserId: 1,
        },
        {
          id: demoId(208),
          clientId: demoId(101),
          retainerBillingId: demoId(811),
          invoiceNumber: `INV-${currentYear}-0007`,
          lifecycle: "sent",
          issueDate: day(-60),
          dueDate: day(-30),
          currencyCode: "USD",
          vatEnabled: true,
          subtotalCents: 80000n,
          vatCents: 8800n,
          totalCents: 88800n,
          sentAt: timestamp(-59),
          sentToEmail: "nour@cedar-stone.example",
          sentPdfStorageKey: "demo/invoices/retainer-0007.pdf",
          sentPdfSha256: "f".repeat(64),
          sentPdfGeneratedAt: timestamp(-59),
          createdByUserId: 1,
        },
      ],
    });

    await tx.invoiceLineItem.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(221),
          invoiceId: demoId(201),
          lineNumber: 1,
          description: "Brand identity design",
          quantity: 1,
          unitPriceCents: 180000n,
          lineTotalCents: 180000n,
        },
        {
          id: demoId(222),
          invoiceId: demoId(201),
          lineNumber: 2,
          description: "Stationery concepts",
          quantity: 2,
          unitPriceCents: 30000n,
          lineTotalCents: 60000n,
        },
        {
          id: demoId(223),
          invoiceId: demoId(202),
          lineNumber: 1,
          description: "Restaurant menu redesign",
          quantity: 1,
          unitPriceCents: 400000n,
          lineTotalCents: 400000n,
        },
        {
          id: demoId(224),
          invoiceId: demoId(202),
          lineNumber: 2,
          description: "Food photography art direction",
          quantity: 1,
          unitPriceCents: 150000n,
          lineTotalCents: 150000n,
        },
        {
          id: demoId(225),
          invoiceId: demoId(203),
          lineNumber: 1,
          description: "Editorial illustration package",
          quantity: 6,
          unitPriceCents: 30000n,
          lineTotalCents: 180000n,
        },
        {
          id: demoId(226),
          invoiceId: demoId(204),
          lineNumber: 1,
          description: "Campaign concept and art direction",
          quantity: 1,
          unitPriceCents: 300000n,
          lineTotalCents: 300000n,
        },
        {
          id: demoId(227),
          invoiceId: demoId(205),
          lineNumber: 1,
          description: "Initial logo exploration",
          quantity: 1,
          unitPriceCents: 80000n,
          lineTotalCents: 80000n,
        },
        {
          id: demoId(228),
          invoiceId: demoId(206),
          lineNumber: 1,
          description: "Packaging consultation",
          quantity: 2,
          unitPriceCents: 62500n,
          lineTotalCents: 125000n,
        },
        {
          id: demoId(229),
          invoiceId: demoId(207),
          lineNumber: 1,
          description: "Spring campaign design",
          quantity: 1,
          unitPriceCents: 95000n,
          lineTotalCents: 95000n,
        },
        {
          id: demoId(230),
          invoiceId: demoId(208),
          lineNumber: 1,
          description: "Monthly brand design support",
          quantity: 8,
          unitPriceCents: 10000n,
          lineTotalCents: 80000n,
        },
      ],
    });

    await tx.invoiceSnapshot.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(241),
          invoiceId: demoId(202),
          studioName: "Haddad Design Studio",
          studioAddress: "12 Cedar Avenue, Beirut, Lebanon",
          studioEmail: "billing@haddad-studio.example",
          studioVatNumber: "LB-DEMO-1042",
          paymentInstructions: "Bank transfer: Haddad Design Studio / Demo account",
          clientContactName: "Karim Mansour",
          clientCompanyName: "Blue Fig Foods",
          clientEmail: "karim@bluefig.example",
          clientBillingAddress: "Mar Mikhael, Beirut, Lebanon",
        },
        {
          id: demoId(242),
          invoiceId: demoId(203),
          studioName: "Haddad Design Studio",
          studioEmail: "billing@haddad-studio.example",
          clientContactName: "Lina Saad",
          clientEmail: "lina@linasaad.example",
          clientBillingAddress: "Byblos, Lebanon",
        },
        {
          id: demoId(243),
          invoiceId: demoId(204),
          studioName: "Haddad Design Studio",
          studioEmail: "billing@haddad-studio.example",
          clientContactName: "Nour Khoury",
          clientCompanyName: "Cedar & Stone Interiors",
          clientEmail: "nour@cedar-stone.example",
        },
        {
          id: demoId(244),
          invoiceId: demoId(206),
          studioName: "Haddad Design Studio",
          studioEmail: "billing@haddad-studio.example",
          clientContactName: "Karim Mansour",
          clientCompanyName: "Blue Fig Foods",
          clientEmail: "karim@bluefig.example",
        },
        {
          id: demoId(245),
          invoiceId: demoId(207),
          studioName: "Haddad Design Studio",
          studioEmail: "billing@haddad-studio.example",
          clientContactName: "Rana Daher",
          clientCompanyName: "Olive Branch Media",
          clientEmail: "rana@olivebranch.example",
        },
        {
          id: demoId(246),
          invoiceId: demoId(208),
          studioName: "Haddad Design Studio",
          studioEmail: "billing@haddad-studio.example",
          clientContactName: "Nour Khoury",
          clientCompanyName: "Cedar & Stone Interiors",
          clientEmail: "nour@cedar-stone.example",
        },
      ],
    });

    await tx.invoicePdfAccessToken.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(261),
          invoiceId: demoId(202),
          tokenHash: "seed-valid-pdf-token-hash",
          expiresAt: timestamp(1),
        },
        {
          id: demoId(262),
          invoiceId: demoId(204),
          tokenHash: "seed-redeemed-pdf-token-hash",
          expiresAt: timestamp(2),
          redeemedAt: timestamp(-1),
        },
        {
          id: demoId(263),
          invoiceId: demoId(206),
          tokenHash: "seed-expired-pdf-token-hash",
          expiresAt: timestamp(-3),
        },
      ],
    });

    await tx.payment.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(271),
          invoiceId: demoId(203),
          amountCents: 70000n,
          paymentDate: day(-3),
          method: "bankTransfer",
          recordedByUserId: 1,
          note: "First installment",
        },
        {
          id: demoId(272),
          invoiceId: demoId(204),
          amountCents: 333000n,
          paymentDate: day(-50),
          method: "cash",
          recordedByUserId: 1,
          note: "Paid in full",
        },
        {
          id: demoId(273),
          invoiceId: demoId(206),
          amountCents: 125000n,
          paymentDate: day(-24),
          method: "other",
          recordedByUserId: 1,
          note: "Card payment later reversed",
        },
      ],
    });

    await tx.paymentReversal.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(281),
          paymentId: demoId(273),
          reversedByUserId: 1,
          reversedAt: timestamp(-22),
          reason: "Client payment was disputed; balance reopened.",
        },
      ],
    });

    await tx.reminderDelivery.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(501),
          invoiceId: demoId(202),
          stage: "beforeDue3Days",
          scheduledFor: timestamp(-21),
          status: "sent",
          sentAt: timestamp(-21),
        },
        {
          id: demoId(502),
          invoiceId: demoId(202),
          stage: "dueDate",
          scheduledFor: timestamp(-18),
          status: "failed",
        },
        {
          id: demoId(503),
          invoiceId: demoId(202),
          stage: "afterDue7Days",
          scheduledFor: timestamp(-11),
          status: "skipped",
          skippedAt: timestamp(-11),
          skipReason: "Reminder paused for client review",
        },
        {
          id: demoId(504),
          invoiceId: demoId(202),
          stage: "afterDue14Days",
          scheduledFor: timestamp(-4),
          status: "pending",
        },
        {
          id: demoId(505),
          invoiceId: demoId(203),
          stage: "beforeDue3Days",
          scheduledFor: timestamp(7),
          status: "processing",
        },
        {
          id: demoId(506),
          invoiceId: demoId(204),
          stage: "afterDue7Days",
          scheduledFor: timestamp(-57),
          status: "cancelled",
          cancelledAt: timestamp(-50),
        },
      ],
    });

    await tx.emailAttempt.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(521),
          invoiceId: demoId(202),
          purpose: "invoiceInitial",
          recipientEmail: "karim@bluefig.example",
          senderName: "Maya Haddad",
          senderEmail: "billing@haddad-studio.example",
          subject: `Invoice INV-${currentYear}-0001 from Haddad Design Studio`,
          body: "Your invoice is attached. Thank you for your business.",
          attachmentStorageKey: "demo/invoices/cedar-0001.pdf",
          providerName: "Demo Mail",
          providerMessageId: "demo-message-initial-001",
          status: "accepted",
          attemptedAt: timestamp(-47),
          acceptedAt: timestamp(-47),
        },
        {
          id: demoId(522),
          invoiceId: demoId(202),
          purpose: "invoiceResend",
          recipientEmail: "karim@bluefig.example",
          subject: `Resending invoice INV-${currentYear}-0001`,
          providerName: "Demo Mail",
          status: "failed",
          attemptedAt: timestamp(-12),
          failureCode: "DEMO_TEMPORARY_FAILURE",
          failureMessage: "Simulated mail provider timeout.",
        },
        {
          id: demoId(523),
          invoiceId: demoId(202),
          reminderDeliveryId: demoId(501),
          purpose: "reminder",
          recipientEmail: "karim@bluefig.example",
          subject: "A friendly reminder about your invoice",
          providerName: "Demo Mail",
          providerMessageId: "demo-message-reminder-001",
          status: "accepted",
          attemptedAt: timestamp(-21),
          acceptedAt: timestamp(-21),
        },
        {
          id: demoId(524),
          invoiceId: demoId(203),
          reminderDeliveryId: demoId(505),
          purpose: "reminder",
          recipientEmail: "lina@linasaad.example",
          subject: "Upcoming invoice due date",
          status: "queued",
          attemptedAt: timestamp(-1),
        },
        {
          id: demoId(525),
          invoiceId: demoId(202),
          reminderDeliveryId: demoId(502),
          purpose: "reminder",
          recipientEmail: "karim@bluefig.example",
          subject: "Invoice payment reminder",
          status: "failed",
          attemptedAt: timestamp(-18),
          failureCode: "DEMO_BOUNCED",
          failureMessage: "Simulated recipient mailbox rejection.",
        },
      ],
    });

    await tx.invoiceEvent.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(541),
          invoiceId: demoId(201),
          actorUserId: 1,
          eventType: "invoiceCreated",
          occurredAt: timestamp(-2),
          details: { source: "manual", demo: true },
        },
        {
          id: demoId(542),
          invoiceId: demoId(202),
          actorUserId: 1,
          eventType: "invoiceSent",
          occurredAt: timestamp(-47),
          details: { recipient: "karim@bluefig.example", demo: true },
        },
        {
          id: demoId(543),
          invoiceId: demoId(202),
          actorUserId: 1,
          emailAttemptId: demoId(522),
          eventType: "emailAttemptFailed",
          occurredAt: timestamp(-12),
          details: { reason: "Simulated provider timeout" },
        },
        {
          id: demoId(544),
          invoiceId: demoId(202),
          actorUserId: 1,
          eventType: "invoiceResent",
          occurredAt: timestamp(-10),
        },
        {
          id: demoId(545),
          invoiceId: demoId(202),
          eventType: "reminderSkipped",
          occurredAt: timestamp(-11),
          details: { reason: "Client reminder pause" },
        },
        {
          id: demoId(546),
          invoiceId: demoId(202),
          emailAttemptId: demoId(523),
          eventType: "reminderSent",
          occurredAt: timestamp(-21),
        },
        {
          id: demoId(547),
          invoiceId: demoId(203),
          actorUserId: 1,
          paymentId: demoId(271),
          eventType: "paymentRecorded",
          occurredAt: timestamp(-3),
          details: { amountCents: 70000, demo: true },
        },
        {
          id: demoId(548),
          invoiceId: demoId(206),
          actorUserId: 1,
          paymentId: demoId(273),
          eventType: "paymentReversed",
          occurredAt: timestamp(-22),
          details: { reason: "Client dispute" },
        },
        {
          id: demoId(549),
          invoiceId: demoId(205),
          actorUserId: 1,
          eventType: "invoiceVoided",
          occurredAt: timestamp(-58),
          details: { reason: "Duplicate invoice" },
        },
      ],
    });

    await tx.jobRun.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(561),
          jobName: "invoice-reminders",
          scheduledFor: timestamp(-1),
          startedAt: timestamp(-1),
          finishedAt: timestamp(-1),
          status: "succeeded",
          processedCount: 12,
        },
        {
          id: demoId(562),
          jobName: "retainer-billing",
          scheduledFor: timestamp(-2),
          startedAt: timestamp(-2),
          finishedAt: timestamp(-2),
          status: "partiallyFailed",
          processedCount: 4,
          errorSummary: "One retainer could not be billed (simulated).",
        },
        {
          id: demoId(563),
          jobName: "invoice-reminders",
          scheduledFor: timestamp(-3),
          startedAt: timestamp(-3),
          finishedAt: timestamp(-3),
          status: "failed",
          processedCount: 0,
          errorSummary: "Simulated provider outage.",
        },
        {
          id: demoId(564),
          jobName: "retainer-billing",
          scheduledFor: timestamp(1),
          startedAt: timestamp(0),
          status: "running",
        },
      ],
    });

    await tx.operationalAlert.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(581),
          emailAttemptId: demoId(522),
          status: "open",
          message: "Invoice resend failed: simulated mail provider timeout.",
          createdAt: timestamp(-12),
        },
        {
          id: demoId(582),
          jobRunId: demoId(562),
          status: "dismissed",
          message: "Retainer billing partially failed (demo).",
          createdAt: timestamp(-2),
          dismissedAt: timestamp(-1),
          dismissedByUserId: 1,
        },
        {
          id: demoId(583),
          jobRunId: demoId(563),
          status: "resolved",
          message: "Reminder job failed; provider recovered (demo).",
          createdAt: timestamp(-3),
          resolvedAt: timestamp(-2),
        },
      ],
    });

    await tx.reminderTemplate.createMany({
      skipDuplicates: true,
      data: [
        {
          id: demoId(601),
          stage: "beforeDue3Days",
          subjectTemplate: "Invoice {{invoiceNumber}} is due soon",
          bodyTemplate: "Hello {{clientName}}, your invoice is due in 3 days.",
          updatedByUserId: 1,
        },
        {
          id: demoId(602),
          stage: "dueDate",
          subjectTemplate: "Invoice {{invoiceNumber}} is due today",
          bodyTemplate: "Hello {{clientName}}, payment is due today.",
          updatedByUserId: 1,
        },
        {
          id: demoId(603),
          stage: "afterDue7Days",
          subjectTemplate: "Reminder: invoice {{invoiceNumber}}",
          bodyTemplate: "Hello {{clientName}}, payment is 7 days overdue.",
          updatedByUserId: 1,
        },
        {
          id: demoId(604),
          stage: "afterDue14Days",
          subjectTemplate: "Overdue invoice {{invoiceNumber}}",
          bodyTemplate: "Hello {{clientName}}, please contact us about this overdue invoice.",
          updatedByUserId: 1,
        },
      ],
    });
  }, { timeout: 30_000 });
}

main()
  .then(async () => {
    console.log("Seeding completed.");
  })
  .catch(async (error) => {
    console.error("Seeding failed:", error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
