resources/views/buyer/invoice/disinvoiceListing.blade.php
Line:476
  @if($invoice->created_by == session('userId') && in_array($invoice->inv_finance_status, [2,4,6]) && $invoice->cbs_status!=3)
                                            @if(\Entrust::can('distributor.invoice.drawdown'))
                                              <li role="presentation"><a class="btn" role="menuitem" tabindex="-1" onclick="invModal(this)" data-amount="{{$invoice->amount}}" data-due_date="{{$invoice->due_date}}" data-invoice_uuid="{{$invoice->uuid}}"  data-req_bank_id="{{$invoice->req_bank_id}}" href="javascript:void(0);">{{trans('label.lbl_edit')}}</a></li>
                                            @endif
                                          @endif
Repository/Eloquent/InvoiceRepo.php
=====================
public function getData()
if ($this->dfInvListing) {
Line:341
$query->leftJoin('cbs_instructions as cbs', function ($join) {
                $join->on('cbs.invoice_id', '=', 'invoices.id')
                    ->where('cbs.credit_type', '=', 3);
            });
$max(cbs.status) as cbs_status





